"""Serve the public status page and a sanitized snapshot of the server.

Only what this script puts in status.json and calendar.ics is published. A
snapshot is taken when one is requested and the last is over 5 minutes old.
"""

import datetime as dt
import http.server
import json
import os
import re
import sys
import threading
import urllib.parse
import urllib.request

port, index_html = sys.argv[1:]
home = os.path.expanduser("~")
max_age = dt.timedelta(minutes=5)

# Rows as shown on the page
SERVICES = [
    {
        "https://stream.ted.ooo/health": "stream.ted.ooo",
        "https://request.ted.ooo/api/v1/status": "request.ted.ooo",
    },
    {
        "http://127.0.0.1:8096/health": "Jellyfin",
        "http://127.0.0.1:5055/api/v1/status": "Seerr",
        "http://127.0.0.1:8080/": "qBittorrent",
        "http://127.0.0.1:3000/api/health": "Grafana",
    },
    {
        "http://127.0.0.1:7878/ping": "Radarr",
        "http://127.0.0.1:8989/ping": "Sonarr",
        "http://127.0.0.1:9696/ping": "Prowlarr",
    },
    {
        "http://127.0.0.1:8191/": "FlareSolverr",
        "http://127.0.0.1:6767/": "Bazarr",
        "http://127.0.0.1:11011/health": "Cleanuparr",
    },
    {
        "http://127.0.0.1:8409/": "ErsatzTV",
        "http://127.0.0.1:5056/health": "tedbot",
    },
]
ARRS = {"sonarr": 8989, "radarr": 7878}

now = None
failed = []


def fetch(url, headers={}):
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=20) as r:
        return json.loads(r.read())


def arr(app, path, **params):
    xml = open(os.path.join(home, f".local/share/{app}/config.xml")).read()
    key = re.search(r"<ApiKey>(.*?)</ApiKey>", xml).group(1)
    query = urllib.parse.urlencode(params)
    return fetch(
        f"http://127.0.0.1:{ARRS[app]}/api/v3/{path}?{query}", {"X-Api-Key": key}
    )


def prom(query):
    q = urllib.parse.urlencode({"query": query})
    return fetch(f"http://127.0.0.1:9090/api/v1/query?{q}")["data"]["result"]


def prom_range(query, start, end, step):
    q = urllib.parse.urlencode(
        {
            "query": query,
            "start": start.timestamp(),
            "end": end.timestamp(),
            "step": step,
        }
    )
    return fetch(f"http://127.0.0.1:9090/api/v1/query_range?{q}")["data"]["result"]


def scalar(query):
    result = prom(query)
    return round(float(result[0]["value"][1]), 1) if result else None


def section(name, fn):
    try:
        return fn()
    except Exception as e:
        print(f"{name}: {e}", file=sys.stderr)
        failed.append(name)
        return None


def by_instance(results, convert):
    return {r["metric"]["instance"]: convert(r["value"][1]) for r in results}


def percent(value):
    return round(float(value) * 100, 2)


def services():
    up = by_instance(prom("probe_success"), lambda v: v == "1")
    month = by_instance(prom("avg_over_time(probe_success[30d])"), percent)
    # Each point is the day ending at the following local midnight
    midnight = (
        dt.datetime.now()
        .astimezone()
        .replace(hour=0, minute=0, second=0, microsecond=0)
    )
    first, last = midnight - dt.timedelta(days=28), midnight + dt.timedelta(days=1)
    days = {}
    for r in prom_range("avg_over_time(probe_success[1d])", first, last, 86400):
        points = {round(float(t)): percent(v) for t, v in r["values"]}
        days[r["metric"]["instance"]] = [
            points.get(round((first + dt.timedelta(days=i)).timestamp()))
            for i in range(30)
        ]
    return [
        [
            {
                "name": name,
                "up": up.get(url),
                "uptime_percent": month.get(url),
                # Daily bars only for the public sites in the first row
                **({"days": days.get(url)} if i == 0 else {}),
            }
            for url, name in row.items()
        ]
        for i, row in enumerate(SERVICES)
    ]


def issues():
    names = {url: name for row in SERVICES for url, name in row.items()}
    seen = {}
    for a in fetch("http://127.0.0.1:9090/api/v1/alerts")["data"]["alerts"]:
        if a["state"] != "firing":
            continue
        labels = a["labels"]
        name = names.get(labels.get("instance"), "A service")
        # Only these fixed messages are published, never raw labels
        text = {
            "ServiceDown": f"{name} is down",
            "PublicSiteDown": f"{name} is down",
            "CertificateExpiring": f"{name} certificate expires soon",
            "DiskSpaceLow": "NAS storage is nearly full"
            if labels.get("mountpoint") == "/Volumes/media"
            else "Server storage is nearly full",
            "JobFailing": "A background job is failing",
        }.get(labels["alertname"], "Some monitoring is not reporting")
        since = a["activeAt"]
        seen[text] = min(seen.get(text, since), since)
    return [{"text": text, "since": since} for text, since in sorted(seen.items())]


def system():
    nas = '{mountpoint="/Volumes/media"}'
    mini = '{mountpoint="/System/Volumes/Data"}'
    return {
        "cpu_percent": scalar(
            '100 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100'
        ),
        "uptime_seconds": scalar("node_time_seconds - node_boot_time_seconds"),
        "nas_free_tb": scalar(f"node_filesystem_avail_bytes{nas} / 1e12"),
        "nas_size_tb": scalar(f"node_filesystem_size_bytes{nas} / 1e12"),
        "nas_free_percent": scalar(
            f"node_filesystem_avail_bytes{nas} / node_filesystem_size_bytes{nas} * 100"
        ),
        "mini_free_gb": scalar(f"node_filesystem_avail_bytes{mini} / 1e9"),
        "mini_size_gb": scalar(f"node_filesystem_size_bytes{mini} / 1e9"),
        "mini_free_percent": scalar(
            f"node_filesystem_avail_bytes{mini} / node_filesystem_size_bytes{mini} * 100"
        ),
        "streams": int(scalar("sum(jellyfin_stream_count) or vector(0)")),
    }


def library():
    counts = {
        r["metric"]["type"]: int(float(r["value"][1]))
        for r in prom("jellyfin_media_count")
    }
    return {
        "movies": counts.get("movies"),
        "shows": counts.get("series"),
        "episodes": counts.get("episodes"),
    }


def downloads():
    # A season pack is one download but appears once per episode in the queue
    torrents = {}
    for app in ARRS:
        for item in arr(app, "queue", pageSize=1000)["records"]:
            if item.get("trackedDownloadState") == "downloading":
                torrents[item["downloadId"]] = (item["size"], item["sizeleft"])
    size = sum(total for total, _ in torrents.values())
    left = sum(remaining for _, remaining in torrents.values())
    return {
        "active": len(torrents),
        "progress_percent": round((1 - left / size) * 100, 1) if size else None,
        "remaining_gb": round(left / 1e9, 1),
    }


def requests():
    settings = json.load(open(os.path.join(home, ".local/share/seerr/settings.json")))
    counts = fetch(
        "http://127.0.0.1:5055/api/v1/request/count",
        {"X-Api-Key": settings["main"]["apiKey"]},
    )
    return {"pending": counts["pending"], "processing": counts["processing"]}


def calendar():
    # Last month through next month, for the page's month navigation
    this_month = now.date().replace(day=1)
    start = (this_month - dt.timedelta(days=1)).replace(day=1)
    end = (this_month + dt.timedelta(days=62)).replace(day=1) - dt.timedelta(days=1)
    window = {"start": start.isoformat(), "end": end.isoformat()}
    events = []
    seasons = {}
    for ep in arr("sonarr", "calendar", includeSeries="true", **window):
        key = (ep["seriesId"], ep["seasonNumber"], ep["airDateUtc"][:10])
        seasons.setdefault(key, []).append(ep)
    for (_, season, _), eps in seasons.items():
        series = eps[0]["series"]
        # A season dropped all at once is one entry, not a row per episode
        if len(eps) >= 3:
            groups = [(f"Season {season} · {len(eps)} episodes", eps)]
        else:
            groups = [
                (
                    f"S{ep['seasonNumber']:02}E{ep['episodeNumber']:02} {ep.get('title') or ''}".strip(),
                    [ep],
                )
                for ep in eps
            ]
        for detail, group in groups:
            events.append(
                {
                    "kind": "episode",
                    "title": series["title"],
                    "detail": detail,
                    "start": min(ep["airDateUtc"] for ep in group),
                    "minutes": series.get("runtime") or 30,
                    "available": all(ep["hasFile"] for ep in group),
                }
            )
    for movie in arr("radarr", "calendar", **window):
        for field, label in [
            ("inCinemas", "In cinemas"),
            ("digitalRelease", "Digital release"),
            ("physicalRelease", "Physical release"),
        ]:
            date = movie.get(field)
            if date and window["start"] <= date[:10] <= window["end"]:
                events.append(
                    {
                        "kind": "movie",
                        "title": f"{movie['title']} ({movie['year']})",
                        "detail": label,
                        "start": date,
                        "allDay": True,
                        "available": movie["hasFile"],
                    }
                )
    return sorted(events, key=lambda e: e["start"])


def ics(events):
    def esc(text):
        return re.sub(r"([,;\\])", r"\\\1", text).replace("\n", "\\n")

    def stamp(iso):
        return dt.datetime.fromisoformat(iso.replace("Z", "+00:00")).strftime(
            "%Y%m%dT%H%M%SZ"
        )

    lines = [
        "BEGIN:VCALENDAR",
        "VERSION:2.0",
        "PRODID:-//status.ted.ooo//calendar//EN",
        "X-WR-CALNAME:ted.ooo",
        "REFRESH-INTERVAL;VALUE=DURATION:PT1H",
    ]
    for e in events:
        uid = re.sub(r"[^A-Za-z0-9]", "", f"{e['title']}{e['detail']}{e['start']}")
        lines += [
            "BEGIN:VEVENT",
            f"UID:{uid}@status.ted.ooo",
            f"DTSTAMP:{stamp(now.isoformat())}",
        ]
        if e.get("allDay"):
            day = dt.date.fromisoformat(e["start"][:10])
            lines += [
                f"DTSTART;VALUE=DATE:{day:%Y%m%d}",
                f"DTEND;VALUE=DATE:{day + dt.timedelta(days=1):%Y%m%d}",
            ]
        else:
            begin = dt.datetime.fromisoformat(e["start"].replace("Z", "+00:00"))
            lines += [
                f"DTSTART:{stamp(e['start'])}",
                f"DTEND:{(begin + dt.timedelta(minutes=e['minutes'])):%Y%m%dT%H%M%SZ}",
            ]
        lines += [
            f"SUMMARY:{esc(e['title'])}",
            f"DESCRIPTION:{esc(e['detail'])}",
            "END:VEVENT",
        ]
    lines.append("END:VCALENDAR")
    return "\r\n".join(lines) + "\r\n"


snapshots = {}
lock = threading.Lock()


def snapshot():
    global now
    now = dt.datetime.now(dt.timezone.utc)
    failed.clear()
    events = section("calendar", calendar)
    status = {
        "updated": now.isoformat(timespec="seconds"),
        "issues": section("issues", issues),
        "services": section("services", services),
        "system": section("system", system),
        "library": section("library", library),
        "downloads": section("downloads", downloads),
        "requests": section("requests", requests),
        "calendar": events,
    }
    snapshots["status.json"] = json.dumps(status, indent=1).encode()
    # Keep the last calendar rather than publishing an empty one
    if events is not None:
        snapshots["calendar.ics"] = ics(events).encode()
    if failed:
        print(f"snapshot incomplete: {', '.join(failed)}", file=sys.stderr)


def latest(name):
    # Concurrent requests wait for one snapshot instead of each taking their own
    with lock:
        if now is None or dt.datetime.now(dt.timezone.utc) - now > max_age:
            snapshot()
        return snapshots.get(name)


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        path = urllib.parse.urlsplit(self.path).path
        if path in ("/", "/index.html"):
            body, kind = open(index_html, "rb").read(), "text/html; charset=utf-8"
        elif path == "/status.json":
            body, kind = latest("status.json"), "application/json"
        elif path == "/calendar.ics":
            body, kind = latest("calendar.ics"), "text/calendar; charset=utf-8"
        elif path == "/health":
            body, kind = b"ok", "text/plain"
        else:
            body = None
        if body is None:
            self.send_error(404)
            return
        self.send_response(200)
        self.send_header("Content-Type", kind)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-cache")
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass


http.server.ThreadingHTTPServer(("127.0.0.1", int(port)), Handler).serve_forever()
