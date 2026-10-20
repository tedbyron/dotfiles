{ pkgs, lib, ... }:
let
  log = "/Users/ted/Library/Logs/jellyfin-posters.log";

  sync = pkgs.writeText "jellyfin-posters.py" ''
    import base64, json, os, subprocess, sys, tempfile, time
    import urllib.error, urllib.parse, urllib.request

    jellyfin_token_file, seerr_settings, state_dir = sys.argv[1:]
    jellyfin_token = open(jellyfin_token_file).read().strip()
    seerr_key = json.load(open(seerr_settings))["main"]["apiKey"]

    magick = "${pkgs.imagemagick}/bin/magick"
    jellyfin_auth = {"Authorization": f'MediaBrowser Token="{jellyfin_token}"'}

    def fetch(url, headers={}, method="GET", data=None):
        req = urllib.request.Request(url, method=method, headers=headers, data=data)
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.read()

    def call(url, headers, method="GET"):
        data = fetch(url, headers, method)
        return json.loads(data) if data else None

    def jellyfin(path, method="GET"):
        return call("http://127.0.0.1:8096" + path, jellyfin_auth, method)

    def seerr(path):
        return call("http://127.0.0.1:5055/api/v1" + path, {"X-Api-Key": seerr_key})

    def download(item_id, image_type, path):
        query = urllib.parse.urlencode(
            {"type": image_type, "imageUrl": f"https://image.tmdb.org/t/p/original{path}"}
        )
        jellyfin(f"/Items/{item_id}/RemoteImages/Download?{query}", "POST")

    def backdrops(item_id):
        images = jellyfin(f"/Items/{item_id}/Images")
        return sorted(
            (i for i in images if i["ImageType"] == "Backdrop"),
            key=lambda i: i.get("ImageIndex") or 0,
        )

    def set_backdrop(item_id, path):
        download(item_id, "Backdrop", path)
        *old, new = backdrops(item_id)
        same = lambda i: (i["Size"], i["Width"], i["Height"]) == (
            new["Size"],
            new["Width"],
            new["Height"],
        )
        dupes = [i.get("ImageIndex") or 0 for i in old if same(i)]
        for index in sorted(dupes, reverse=True):
            jellyfin(f"/Items/{item_id}/Images/Backdrop/{index}", "DELETE")
        index = (new.get("ImageIndex") or 0) - len(dupes)
        if index:
            jellyfin(f"/Items/{item_id}/Images/Backdrop/{index}/Index?newIndex=0", "POST")

    def mean(*args):
        out = subprocess.run([magick, *args, "-format", "%[fx:mean]", "info:"],
                             capture_output=True, text=True, check=True)
        return float(out.stdout)

    def brightness(logo, *measure):
        alpha = mean(logo, "-alpha", "extract")
        lit = mean(logo, "-alpha", "off", *measure, "(", logo, "-alpha", "extract", ")",
                   "-compose", "multiply", "-composite")
        return lit / alpha if alpha else 1

    def set_thumb(item_id, backdrop):
        try:
            logo_data = fetch(f"http://127.0.0.1:8096/Items/{item_id}/Images/Logo", jellyfin_auth)
        except urllib.error.HTTPError:
            download(item_id, "Thumb", backdrop)
            return

        with tempfile.TemporaryDirectory() as tmp:
            bg, base, logo, out = (
                os.path.join(tmp, f) for f in ("bg.jpg", "base.png", "logo.png", "thumb.jpg")
            )
            open(bg, "wb").write(fetch(f"https://image.tmdb.org/t/p/w1280{backdrop}"))
            open(logo, "wb").write(logo_data)

            subprocess.run([
                magick, bg, "-resize", "1280x720^", "-gravity", "center", "-extent", "1280x720",
                "(", "-size", "1280x720", "gradient:none-rgba(0,0,0,0.55)", ")", "-composite", base,
            ], check=True, capture_output=True)

            # Flip the logo only when it nearly matches the backdrop behind it
            # Brightest channel, so saturated colors like red don't count as dark
            logo_value = brightness(logo, "-colorspace", "HSB", "-channel", "B", "-separate", "+channel")
            logo_luma = brightness(logo, "-colorspace", "Gray")
            area_level = mean(base, "-gravity", "south", "-crop", "640x260+0+50", "+repage",
                              "-colorspace", "Gray")
            recolor = []
            if logo_value < 0.3 and area_level < 0.4:
                recolor = ["-fill", "white", "-colorize", "100"]
            elif logo_luma > 0.7 and area_level > 0.6:
                recolor = ["-fill", "black", "-colorize", "100"]

            subprocess.run([
                magick, base, "(", logo, "-trim", *recolor, "-resize", "640x260", ")",
                "-gravity", "south", "-geometry", "+0+50", "-composite", "-quality", "90", out,
            ], check=True, capture_output=True)

            fetch(f"http://127.0.0.1:8096/Items/{item_id}/Images/Thumb",
                  {**jellyfin_auth, "Content-Type": "image/jpeg"}, "POST",
                  base64.b64encode(open(out, "rb").read()))

    def load(name):
        path = os.path.join(state_dir, name)
        return json.load(open(path)) if os.path.exists(path) else {}

    def save(name, data):
        path = os.path.join(state_dir, name)
        with open(path + ".tmp", "w") as f:
            json.dump(data, f, indent=2)
        os.replace(path + ".tmp", path)

    for _ in range(60):
        try:
            jellyfin("/System/Info/Public")
            seerr("/status")
            break
        except OSError:
            time.sleep(10)

    posters, backdrops_done = load("posters.json"), load("backdrops.json")
    thumbs = load("thumbs.json")
    failed = 0

    items = jellyfin(
        "/Items?Recursive=true&IncludeItemTypes=Movie,Series&CollapseBoxSetItems=false&Fields=ProviderIds"
    )["Items"]

    for item in items:
        tmdb = item.get("ProviderIds", {}).get("Tmdb")
        if not tmdb or all(item["Id"] in d for d in (posters, backdrops_done, thumbs)):
            continue

        kind = "movie" if item["Type"] == "Movie" else "tv"
        try:
            details = seerr(f"/{kind}/{tmdb}")
            poster, backdrop = details.get("posterPath"), details.get("backdropPath")
            if poster and item["Id"] not in posters:
                download(item["Id"], "Primary", poster)
                posters[item["Id"]] = poster
                print(f"set {item['Name']} poster to {poster}")
            if backdrop and item["Id"] not in backdrops_done:
                set_backdrop(item["Id"], backdrop)
                backdrops_done[item["Id"]] = backdrop
                print(f"set {item['Name']} backdrop to {backdrop}")
            if backdrop and item["Id"] not in thumbs:
                set_thumb(item["Id"], backdrop)
                thumbs[item["Id"]] = backdrop
                print(f"set {item['Name']} thumb to {backdrop}")
        except Exception as e:
            print(f"failed {item['Name']}: {e}")
            failed += 1

    os.makedirs(state_dir, exist_ok=True)
    save("posters.json", posters)
    save("backdrops.json", backdrops_done)
    save("thumbs.json", thumbs)
    sys.exit(1 if failed else 0)
  '';
in
{
  launchd.user.agents.jellyfin-posters.serviceConfig = {
    ProgramArguments = lib.ted.waitForNix [
      "${pkgs.python3}/bin/python3"
      "-I"
      "${sync}"
      "/Users/ted/.config/jelly-metrics/token"
      "/Users/ted/.local/share/seerr/settings.json"
      "/Users/ted/.local/share/jellyfin-posters"
    ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
    StartInterval = 3600;
  };
}
