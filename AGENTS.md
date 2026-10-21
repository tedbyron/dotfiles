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

- Services are launchd user agents bound to `127.0.0.1`. App data lives in
  `~/.local/share/<app>` (SQLite, keep it off the NAS), logs in
  `~/Library/Logs/<app>.log`.
- New services: add to `modules/default.nix`, a probe in `prometheus.nix`, and a
  source in `backup.nix`.
- `backup.nix` archives app data nightly at 4am (SQLite via `.backup`) to
  `~/Backups/media/archives`, then copies it to `/Volumes/media/backups`; each
  keeps the newest 14. The local archive is written before waiting for the NAS,
  so a down NAS only delays the copy.
- Media is on a Synology NFS share at `/Volumes/media` (`downloads/`, `movies/`,
  `tv/`, `anime/`, `anime-movies/`, `backups/`), mounted by `nas.nix`. Downloads
  and library must stay in that one share so Radarr/Sonarr imports are
  hardlinks. Services that touch media wait for the mount before starting.
- The share is btrfs with data checksums on (only settable at share creation),
  and a single HDD, so random I/O is the bottleneck. `downloads/` and its
  subfolders have `chattr +C` (set over SSH on the NAS, user `ted`, needs a
  password) so new torrent files skip copy-on-write and checksums; redo it if
  the share is recreated. The NFS mount uses 128K rsize/wsize (256K tested no
  faster) and readahead 128 (the macOS max); macOS's client only speaks NFSv4.0,
  so it stays on v3.
- The NAS and the mini are both on a 2.5GbE switch (~260 MB/s NFS reads from the
  NAS's cache). The NAS's two ports are an Active/Standby bond with the 2.5GbE
  port active; the 1GbE port is only a backup link, so it never caps a client at
  1GbE.
- The NAS is a DS425+ (DSM 7.3, 2 GB RAM). A Samsung 990 Pro in an M.2 slot is a
  ~500 GB read-only SSD cache (skip sequential I/O on). DSM 7.3 blocks caches on
  unlisted NVMe drives, so 007revad's Synology_HDD_db (`syno_hdd_db.sh -n`) runs
  as a root boot task in DSM's Task Scheduler; after a DSM update the cache may
  need a reboot to come back. Async NFS writes are on and file access times are
  never recorded. Shut the NAS down only after stopping the media services and
  unmounting `/Volumes/media` (the mount is `hard`, so services hang otherwise);
  `nas.nix` remounts it within 30s of the NAS coming back.
- qBittorrent is bound to the Proton WireGuard tunnel; `qbittorrent.nix`
  rebuilds the tunnel when DNS through it fails, and renews Proton's NAT-PMP
  forwarded port (restarting qBittorrent when the port changes). The private key
  is in `/etc/wireguard/proton.key`.
- Never torrent outside the VPN. qBittorrent must only run through its start
  script, which waits for the tunnel, binds to it, and stops if it changes.
  Don't remove the interface binding, start qBittorrent any other way, or add
  another torrent client without the same protection.
- Prebuilt binaries (Cleanuparr, ErsatzTV's ffmpeg) are packaged from release
  archives with `dontFixup = true`.
- Radarr/Sonarr quality settings follow the TRaSH Guides (trash-guides.info):
  `recyclarr.nix` uses TRaSH's profiles, sizes and default format groups with no
  overrides. Before changing profiles, scores, or Radarr/Sonarr settings TRaSH
  covers, check the guides and follow them. The cached guide data is in
  `~/Library/Application Support/recyclarr/resources/trash-guides/`.
- Grafana dashboards in `modules/grafana/` are provisioned v2 JSON, exported
  from the `resource` table in `~/.local/share/grafana/grafana.db`.
- App settings not in nix (Radarr, Sonarr, Seerr, Jellyfin libraries,
  Cleanuparr) can be read and changed through each app's local API. API keys are
  in `~/.local/share/{radarr,sonarr,prowlarr}/config.xml`,
  `~/.local/share/seerr/settings.json` and `~/.config/jelly-metrics/token`
  (Jellyfin).

### Settings that live in the apps

Not in nix (their APIs change between versions); restored from the nightly
backups. Redo by hand after a rebuild without backups:

- Prowlarr: every indexer seeds to ratio 1 or 7 days (synced to Radarr/Sonarr,
  which set it per torrent); Standard sync profile minimum seeders 5; Internet
  Archive removed (slow, no grabs); Knaben priority 50 (stale seeder counts);
  FlareSolverr proxy tagged on 1337x, EZTV and Uindex; Anime Tosho (public
  feed.animetosho.net definition) beside Nyaa for anime, Sonarr only since it
  has no movie categories.
- Sonarr/Radarr: root folders `/Volumes/media/{tv,anime}` and
  `/Volumes/media/{movies,anime-movies}` (Seerr sends anime requests to the
  anime folders); Emby/Jellyfin connection for rescans; propers and repacks set
  to Do not Prefer (the Repack/Proper custom formats score them); rescan folder
  after refresh only after manual refresh (they make every file change
  themselves, so the scheduled refreshes don't need to stat the whole library
  over NFS); delete empty folders on; no recycle bin (the NAS doesn't support
  one); import extra files `srt,ass,ssa,sub,idx`; delay profile prefers torrent
  with a 6h delay, bypassed only for releases scoring 1700+ (TRaSH's WEB Tier
  01), not for the top quality, since every WEB-1080p release is the top quality
  in Sonarr's profile; qBittorrent client removes completed downloads and moves
  imports to `radarr-imported`/`tv-sonarr-imported`. Quality profiles and naming
  come from Recyclarr. Anime uses TRaSH's [Anime] Remux-1080p in both apps,
  except Star Wars: Visions, which stays on WEB-1080p: its Disney+ releases
  score under the anime profile's minimum of 100, so new seasons would never be
  grabbed.
- Cleanuparr: queue cleaner every 15 min; failed import 3 strikes, downloading
  metadata 6, errored 3; stall rules 0-80% (4 strikes) and 80-100% (15 strikes),
  reset after 10MB progress; seeker runs replacement and proactive searches
  every 10 min (round robin, each item at most weekly, monitored only, up to the
  quality and custom format score cutoffs in both apps, paused at 3 active
  downloads, 6h post-release grace); download cleaner off.
- Seerr: Radarr/Sonarr default profiles HD Bluray + WEB and WEB-1080p, and
  [Anime] Remux-1080p for anime (specials, libraries and root folders are set in
  `seerr.nix`). Seerr has no anime setting for Radarr, so an override rule
  (Settings → Services → Radarr) sends movies with TMDb's anime keyword (210024)
  to `anime-movies/` with the anime profile. The owner (user 1, the only admin)
  is Jellyfin `ted`, which Jellyfin only lets sign in locally; `tb` is a normal
  user. Seerr's owner can't be demoted or changed from the UI, so sign in as
  `ted` first when setting it up.
- Jellyfin: Movies, Shows, Anime and Anime Movies libraries on `/Volumes/media`
  (the anime ones copy Movies' and Shows' options with AniDB then AniList first
  for series, season and movie metadata; episodes keep TMDb first so numbering
  matches Sonarr). Plugins beyond the bundled ones: Intro Skipper, Playback
  Reporting, Jellyscribe (GitHub manifest), File Transformation, StreamLimiter,
  Fanart, AniList and AniDB (metadata providers; AniDB uses its own built-in API
  client and matches through TVDB IDs, since its title matching fails with an
  XmlReader async error in 13.0.0.0), Jellyfin Enhanced (n00bcodr's manifest;
  needs File Transformation; ratings from TMDB and Rotten Tomatoes, plus IMDb
  and others through an MDBList key; users pick their own features in its `?`
  panel). `jellyfin.nix` sets one fallback font (IPAexGothic) for ASS subtitles
  without attached fonts; keep it small, the web player downloads every fallback
  font before showing ASS subtitles. Custom CSS (Dashboard → Branding) hides the
  native star rating and the native text external links, leaving Jellyfin
  Enhanced's ratings row and its own icon links (`letterboxd-link`,
  `seerr-link`, `arr-link`, `arr-tag-link`). Transcoding uses VideoToolbox with
  HDR tone mapping, throttling and segment deletion on. Trickplay is extracted
  during library scans (non-blocking, below-normal priority, one thread), and
  Intro Skipper analyzes new media automatically. Both read whole files over
  NFS, so they compete with playback during big import waves. `jellyfin.nix`
  gives users without a home layout `tb`'s home sections and library order.
- ErsatzTV: Jellyfin as the media source; re-sync it and reset playouts after
  library paths change. It discovers new Jellyfin libraries only at startup,
  with sync off; `ersatztv.nix` turns sync on for all of them on the next start.
  Channels pick content by search query, not by library.
- Bazarr: subtitle sync only for subtitles scoring under 90 (episodes) and 70
  (movies); syncing extracts the whole file's audio over NFS. AnimeTosho
  provider on, with the AniDB HTTP API client `bazarrtedster` version 9 (in both
  the AniDB and AnimeTosho settings); it needs the AniDB episode ID, which needs
  that client. `bazarr.nix` patches the provider for AnimeTosho's new domain and
  API and fixes the AniDB refiner's episode ID; drop the patch once upstream
  fixes them (the build fails when the replaced text changes).

### Gotchas

- Bazarr's start script runs `pkill -9 -f "bazarr/main.py --config …"`, which
  also kills any shell whose command line contains that text; start Bazarr in a
  command of its own and don't mention its path there.
- NFS reports no file creation time (it reads as 1970), so Jellyfin's
  `UseFileCreationTimeForDateAdded` is kept off in `jellyfin.nix`.
- `rsync -a` and `cp -p` to the NAS fail setting owners; use `rsync -rlpt`.
  macOS's `/usr/bin/rsync` is openrsync; use nixpkgs rsync for `-H`.
- `stat`, `sed`, `date` and friends on `PATH` are GNU coreutils, not BSD.
