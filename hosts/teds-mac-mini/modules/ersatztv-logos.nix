{ pkgs, lib, ... }:
let
  dataDir = "/Users/ted/Library/Application Support/ersatztv";
  log = "/Users/ted/Library/Logs/ersatztv-logos.log";

  # Jellyfin's guide hides a channel's name when it has a logo, so the logo
  # carries the name. Jellyfin only takes the M3U logo for a channel without
  # one, so it's uploaded there directly too.
  sync = pkgs.writeText "ersatztv-logos.py" ''
    import base64, datetime, hashlib, json, os, sqlite3, subprocess, sys, tempfile
    import urllib.request

    db_path, logo_dir, jellyfin_token_file, state_dir = sys.argv[1:]
    jellyfin_auth = {
        "Authorization": f'MediaBrowser Token="{open(jellyfin_token_file).read().strip()}"'
    }

    magick = "${pkgs.imagemagick}/bin/magick"
    font = "${pkgs.montserrat}/share/fonts/ttf/Montserrat-Bold.ttf"
    colors = ["#874c40", "#3f6866", "#664c6e", "#86693f", "#4a5a7a", "#5a6b4a", "#764a5a", "#4e5964"]
    LOGO = 2

    def fetch(url, headers={}, method="GET", data=None):
        req = urllib.request.Request(url, method=method, headers=headers, data=data)
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.read()

    def jellyfin(path):
        return json.loads(fetch("http://127.0.0.1:8096" + path, jellyfin_auth))

    def render(name, number):
        color = colors[(int(float(number)) - 1) % len(colors)]
        with tempfile.TemporaryDirectory() as tmp:
            out = os.path.join(tmp, "logo.png")
            subprocess.run([
                magick, "-size", "800x400", "xc:none", "-fill", color,
                "-draw", "roundrectangle 0,0 799,399 64,64",
                "(", "-background", "none", "-fill", "white", "-font", font,
                "-size", "680x240", "-gravity", "center", f"label:{name}", ")",
                "-gravity", "center", "-composite", "-strip", out,
            ], check=True, capture_output=True)
            return open(out, "rb").read()

    def logo_path(digest):
        return os.path.join(logo_dir, digest[:2], digest)

    state_file = os.path.join(state_dir, "state.json")
    state = json.load(open(state_file)) if os.path.exists(state_file) else {}
    generated, uploaded = set(state.get("generated", [])), state.get("uploaded", {})

    db = sqlite3.connect(db_path, timeout=30)
    channels = db.execute("""
        SELECT c.Id, c.Number, c.Name, a.Id, a.Path FROM Channel c
        LEFT JOIN Artwork a ON a.ChannelId = c.Id AND a.ArtworkKind = ?
    """, (LOGO,)).fetchall()

    logos = {}
    for channel_id, number, name, artwork_id, path in channels:
        # Keep logos uploaded in ErsatzTV; replace missing, URL and generated ones
        if path and "://" not in path and path not in generated:
            logos[number] = path
            continue

        png = render(name, number)
        digest = hashlib.md5(png).hexdigest()
        logos[number] = digest
        generated.add(digest)
        if not os.path.exists(logo_path(digest)):
            os.makedirs(os.path.dirname(logo_path(digest)), exist_ok=True)
            open(logo_path(digest), "wb").write(png)
        if path == digest:
            continue

        now = datetime.datetime.now(datetime.UTC).strftime("%Y-%m-%d %H:%M:%S.%f")
        with db:
            if artwork_id:
                db.execute(
                    "UPDATE Artwork SET Path = ?, OriginalContentType = 'image/png', DateUpdated = ? WHERE Id = ?",
                    (digest, now, artwork_id),
                )
            else:
                db.execute(
                    "INSERT INTO Artwork (ArtworkKind, ChannelId, Path, OriginalContentType, DateAdded, DateUpdated) VALUES (?, ?, ?, 'image/png', ?, ?)",
                    (LOGO, channel_id, digest, now, now),
                )
        print(f"set {name} logo to {digest}")

    for channel in jellyfin("/LiveTv/Channels")["Items"]:
        digest = logos.get(channel.get("ChannelNumber"))
        if not digest or uploaded.get(channel["Id"]) == digest:
            continue
        png = fetch(f"http://127.0.0.1:8409/iptv/logos/{digest}.jpg")
        fetch(f"http://127.0.0.1:8096/Items/{channel['Id']}/Images/Primary",
              {**jellyfin_auth, "Content-Type": "image/png"}, "POST", base64.b64encode(png))
        uploaded[channel["Id"]] = digest
        print(f"uploaded {channel['Name']} logo to jellyfin")

    os.makedirs(state_dir, exist_ok=True)
    with open(state_file + ".tmp", "w") as f:
        json.dump({"generated": sorted(generated), "uploaded": uploaded}, f, indent=2)
    os.replace(state_file + ".tmp", state_file)
  '';
in
{
  launchd.user.agents.ersatztv-logos.serviceConfig = {
    ProgramArguments = lib.ted.waitForNix [
      "${pkgs.python3}/bin/python3"
      "-I"
      "${sync}"
      "${dataDir}/ersatztv.sqlite3"
      "${dataDir}/cache/artwork/logos"
      "/Users/ted/.config/jelly-metrics/token"
      "/Users/ted/.local/share/ersatztv-logos"
    ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
    StartInterval = 3600;
  };
}
