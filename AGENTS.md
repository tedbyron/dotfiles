# AGENTS.md

Nix flake for nix-darwin, NixOS, and home-manager configs.

## Layout

- `flake.nix`: inputs, overlays, and the host list (`darwinConfigurations`,
  `nixosConfigurations`)
- `lib/`: `lib.ted` helpers; `mkSystem.nix` wires home-manager, stylix,
  `modules/`, and `hosts/<host>`
- `modules/`: system modules shared by all hosts, with `darwin/` and `nixos/`
  subsets
- `hosts/<host>/default.nix`: per-host config, imports from `users/`
- `users/ted/`: user account and home-manager config (`programs/`, `modules/`,
  `file.nix`, `packages.nix`)
- `hosts/teds-mac-mini/modules/`: media server stack (Jellyfin, servarr,
  monitoring) for the mac mini
- `config/`: raw dotfiles, linked into `$HOME` via `lib.ted.configPath`
- `packages/`: local packages, exposed as flake `packages` outputs
- `bin/`: scripts on `PATH`
- `flakes/`, `templates/`: local flake inputs and `nix flake init` templates

Module args include `darwin`, `wsl`, and `unstable` (nixpkgs-unstable) via
`specialArgs`. Use `unstable.<pkg>` when a package needs to be newer than the
stable channel.

## Commands

- `just build`: build the current host's config without activating it
- `just check`: run `nix flake check`
- `just format`: run treefmt (nixfmt, deadnix, statix, prettier, stylua, etc.)
- Build another host: `nix build .#darwinConfigurations.<host>.system` or
  `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`

Don't run `just switch`, `boot`, `test`, or `rollback`; ask first. New files
must be `git add`ed before flake evaluation can see them.

## Conventions

- Match the existing style: nixfmt formatting, `lib.optionalAttrs` for
  darwin/linux splits, `baseNameOf (toString ./.)` for host names.
- Run `just format` after editing.
- Never commit unless explicitly asked for that specific commit.

## Mac mini media stack

- Services are launchd user agents bound to `127.0.0.1`; data in
  `~/.local/share/<app>` (SQLite, keep it off the NAS), logs in
  `~/Library/Logs/<app>.log`. A new service needs an entry in
  `modules/default.nix`, a probe in `prometheus.nix`, and a source in
  `backup.nix` (nightly archives to `~/Backups/media/archives` and the NAS).
- Media is on a Synology NFS share at `/Volumes/media` (`downloads/`, `movies/`,
  `tv/`, `anime/`, `anime-movies/`, `orphaned/`, `backups/`), mounted by
  `nas.nix`. Downloads and library must share it so imports are hardlinks;
  services that touch media wait for the mount.
- The NAS is a DS425+ (DSM 7.3, 2 GB RAM) with one HDD on btrfs with data
  checksums, so random I/O is the bottleneck. `downloads/` has `chattr +C` (set
  over SSH on the NAS as `ted`, needs a password; redo if the share is
  recreated). A Samsung 990 Pro is a ~500 GB read-only SSD cache, enabled on DSM
  7.3 by 007revad's `syno_hdd_db.sh -n` as a root boot task; after a DSM update
  it may need a reboot. Async NFS writes on, access times off. NAS and mini
  share a 2.5GbE switch (~260 MB/s cached reads); the NAS's 1GbE port is only a
  standby link. NFS stays on v3 (macOS only speaks v4.0); 256K rsize/wsize
  tested no faster than 128K; readahead stays at the default 16 (128 made
  qBittorrent read ~4x what it served).
- Shut the NAS down only after stopping the media services and unmounting
  `/Volumes/media` (the mount is `hard`); `nas.nix` remounts within 30s.
- Never torrent outside the VPN. qBittorrent must only run through its start
  script, which waits for the Proton WireGuard tunnel, binds to it, and stops if
  it changes. Don't remove the binding, start it any other way, or add another
  client without the same protection. The key is `/etc/wireguard/proton.key`.
- Radarr/Sonarr quality settings follow the TRaSH Guides with no overrides
  (`recyclarr.nix`). Check the guides before changing anything they cover;
  cached copy in
  `~/Library/Application Support/recyclarr/resources/trash-guides/`.
- Grafana dashboards in `modules/grafana/` are provisioned v2 JSON, exported
  from the `resource` table in `~/.local/share/grafana/grafana.db`.
- Prebuilt binaries (Cleanuparr, ErsatzTV's ffmpeg) are packaged from release
  archives with `dontFixup = true`.
- App settings are changed through each app's local API. Keys are in
  `~/.local/share/{radarr,sonarr,prowlarr}/config.xml`,
  `~/.local/share/seerr/settings.json` (`main.apiKey`) and
  `~/.config/jelly-metrics/token` (Jellyfin).

### Settings that live in the apps

Not in nix (their APIs change between versions); restored from the nightly
backups. Redo by hand after a rebuild without backups:

- Prowlarr: every indexer seeds to ratio 1 or 7 days; Standard sync profile
  minimum seeders 5; Internet Archive removed; Knaben priority 50 (stale seeder
  counts); FlareSolverr tag on 1337x, EZTV and Uindex; Anime Tosho (public
  definition) beside Nyaa, synced to Sonarr only (no movie categories).
- Sonarr/Radarr: root folders `tv`, `anime`, `movies`, `anime-movies`; Jellyfin
  connection for rescans; propers and repacks Do not Prefer (custom formats
  score them); rescan folder after refresh only after manual refresh (avoids
  statting the library over NFS); delete empty folders on; no recycle bin;
  import extra files `srt,ass,ssa,sub,idx`; delay profile prefers torrent, 6h
  delay, bypassed only at score 1700+ (TRaSH's WEB Tier 01); qBittorrent client
  removes completed downloads, categories
  `radarr-imported`/`tv-sonarr-imported`. Anime uses [Anime] Remux-1080p except
  Star Wars: Visions (WEB-1080p; its Disney+ releases score under the anime
  minimum of 100).
- Cleanuparr: queue cleaner every 15 min; strikes: failed import 4, downloading
  metadata 6, errored 4, stalled 6 (0-80%) or 16 (80-100%, so nearly done
  downloads get more time), reset after 10MB; slow (under 20 KB/s) 16, never
  reset (catches dead torrents that trickle from partial peers and so never
  count as stalled); seeker every 10 min (round robin, each item at most weekly,
  monitored only, up to both cutoffs, paused at 3 active downloads, 6h grace);
  download cleaner every 6h with no seeding rules, only orphaned files: anything
  in `downloads/` no torrent uses, after 24h, moves to `orphaned/` and is purged
  after 72h.
- Seerr: default profiles HD Bluray + WEB, WEB-1080p, and [Anime] Remux-1080p
  for anime (folders and libraries are set in `seerr.nix`). An override rule
  (Settings → Services → Radarr) sends movies with TMDb's anime keyword (210024)
  to `anime-movies/` with the anime profile. The owner is Jellyfin `ted` (local
  sign-in only, can't be changed later), so sign in as `ted` first on a fresh
  setup; `tb` is a normal user. CSRF protection (Settings → Network) is off:
  with it on, Seerr refuses every non-browser POST, including Moonfin's sign-in
  and webhook setup, Jellyfin Enhanced's user import and the Serializd sync.
- Jellyfin: libraries Movies, Shows, Anime, Anime Movies (anime ones put AniDB
  then AniList first, except episodes, which keep TMDb to match Sonarr's
  numbering). Extra plugins: Intro Skipper, Playback Reporting, Jellyscribe
  (GitHub manifest), File Transformation, StreamLimiter, Fanart, AniList, AniDB
  (built-in API client; title matching is broken in 13.0.0.0, so it matches by
  TVDB ID), TMDb Box Sets, Jellyfin Enhanced (n00bcodr's manifest, MDBList key),
  Moonbase (Moonfin's server plugin, Moonfin-Client manifest), Subtitle Extract
  (all libraries; subtitles and attachments nightly at 2:05/2:15, capped at 45
  min so they finish before Trickplay and backups), SkipMe.db (Intro Skipper
  manifest; crowd-sourced segments, synced at 1:00 before Intro Skipper),
  Session Cleaner (90 days, Sundays). Custom CSS (Dashboard → General) hides the
  native star and critic ratings, ends-at times (item pages and player), the
  text external links (keeping Jellyfin Enhanced's icon links:
  `letterboxd-link`, `letterboxd-link-icon`, `seerr-link`, `arr-link`,
  `arr-tag-link`) and Moonfin's header button, and restyles the poster count and
  played badges as translucent primary-color pills. VideoToolbox transcoding
  with tone mapping, throttling and segment deletion; HEVC encoding allowed, AV1
  off (no VideoToolbox AV1 encoder, so it would be software). Trickplay (one
  thread) reads whole files over NFS, so it runs only in its nightly task (3:00,
  capped at 1h), not during scans.
- ErsatzTV: Jellyfin as the media source; channels pick content by search, not
  library. Re-sync and reset playouts after library paths change. Channel logos
  are generated by `ersatztv-logos.nix` (Jellyfin's guide shows only the logo,
  not the name) unless one is uploaded in ErsatzTV.
- Bazarr: sync only subtitles scoring under 90 (episodes) / 70 (movies), since
  it reads the whole file's audio over NFS. AnimeTosho provider uses the AniDB
  HTTP client `bazarrtedster` v9; `bazarr.nix` patches the provider and the
  AniDB refiner (drop it once upstream fixes them; the build fails if the
  patched text changes). TVsubtitles is removed (403 since Oct 2026).

### Gotchas

- Bazarr's start script runs `pkill -9 -f "bazarr/main.py --config …"`, which
  also kills any shell whose command line contains that text; start Bazarr in a
  command of its own and don't mention its path there.
- NFS reports no file creation time (it reads as 1970), so Jellyfin's
  `UseFileCreationTimeForDateAdded` stays off.
- `rsync -a` and `cp -p` to the NAS fail setting owners; use `rsync -rlpt`.
  macOS's `/usr/bin/rsync` is openrsync; use nixpkgs rsync for `-H`.
- ErsatzTV finds new Jellyfin libraries only at startup, with sync off;
  `ersatztv.nix` turns sync on at the following start.
