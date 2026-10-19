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
- `users/ted/modules/media/`: media server stack (Jellyfin, servarr,
  monitoring), imported by `teds-mac-mini`
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
