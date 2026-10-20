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
- Never commit unless explicitly asked for that specific commit. Leave changes
  uncommitted and report what's pending.

## Mac mini media stack

- Services are launchd user agents bound to `127.0.0.1`. App data lives in
  `~/.local/share/<app>` (SQLite, keep it off the NAS), logs in
  `~/Library/Logs/<app>.log`.
- New services: add to `modules/default.nix`, a probe in `prometheus.nix`, and a
  source in `backup.nix`.
- Media is on a Synology NFS share at `/Volumes/media` (`downloads/`, `movies/`,
  `tv/`, `backups/`), mounted by `nas.nix`. Downloads and library must stay in
  that one share so Radarr/Sonarr imports are hardlinks. Services that touch
  media wait for the mount before starting.
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

- Prowlarr: Standard sync profile minimum seeders 5; Internet Archive disabled
  (slow, no grabs); Knaben priority 50 (stale seeder counts); FlareSolverr proxy
  tagged on 1337x, EZTV and Uindex.
- Sonarr/Radarr: root folders `/Volumes/media/{tv,movies}`; Emby/Jellyfin
  connection for rescans; propers and repacks set to Do not Prefer (the
  Repack/Proper custom formats score them); delete empty folders on; no recycle
  bin (the NAS doesn't support one); import extra files `srt,ass,ssa,sub,idx`;
  delay profile prefers torrent with a 30 min delay (bypassed for the top
  quality); qBittorrent client removes completed downloads and moves imports to
  `radarr-imported`/`tv-sonarr-imported`. Quality profiles and naming come from
  Recyclarr.
- Cleanuparr: queue cleaner every 15 min; failed import 3 strikes, downloading
  metadata 6, errored 3; stall rules 0-80% (4 strikes) and 80-100% (15 strikes),
  reset after 10MB progress; seeker runs replacement and proactive searches
  every 10 min (round robin, each item at most weekly, monitored only, up to
  cutoff, paused at 3 active downloads, 6h post-release grace); download cleaner
  off.
- Seerr: Radarr/Sonarr default profiles HD Bluray + WEB and WEB-1080p (specials,
  libraries and root folders are set in `seerr.nix`). The owner (user 1, the
  only admin) is Jellyfin `ted`, which Jellyfin only lets sign in locally; `tb`
  is a normal user. Seerr's owner can't be demoted or changed from the UI, so
  sign in as `ted` first when setting it up.
- Jellyfin: Movies and Shows libraries on `/Volumes/media`; plugins Intro
  Skipper, Playback Reporting, Jellyscribe (GitHub manifest), File
  Transformation, StreamLimiter. Transcoding uses VideoToolbox with HDR tone
  mapping, throttling and segment deletion on.
- ErsatzTV: Jellyfin as the media source; re-sync it and reset playouts after
  library paths change.

### Gotchas

- NFS reports no file creation time (it reads as 1970), so Jellyfin's
  `UseFileCreationTimeForDateAdded` is kept off in `jellyfin.nix`.
- `rsync -a` and `cp -p` to the NAS fail setting owners; use `rsync -rlpt`.
  macOS's `/usr/bin/rsync` is openrsync; use nixpkgs rsync for `-H`.
- `stat`, `sed`, `date` and friends on `PATH` are GNU coreutils, not BSD.
