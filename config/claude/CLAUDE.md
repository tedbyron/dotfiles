# Project instructions

If a repository has an `AGENTS.md` file, follow it as the project's instructions
instead of `CLAUDE.md`.

## Shell environment

Coreutils and common command-line tools on `PATH` (`ls`, `stat`, `date`, `dd`,
`sed`, `grep`, `awk`, `find`, `xargs`, etc.) are the GNU versions from nixpkgs,
including on macOS. Use GNU flags and syntax, not BSD.

Prefer `rg` (ripgrep) over `grep` for searching files: it's recursive by
default, respects `.gitignore`, and filters by type (`rg -t nix pattern`) or
glob (`rg -g '*.nix' pattern`). Keep `grep` for filtering piped output.

The shell is zsh, not bash:

- Unquoted variables aren't word-split: `for s in $list` loops once over the
  whole string. Use an array (`list=(a b c)`) or `${=list}`.
- An unmatched glob is an error (`no matches found`), so quote patterns passed
  to commands, e.g. `grep --include='*.nix'`.
- Bash builtins like `mapfile`/`readarray` don't exist; write a bash script
  (`#!/usr/bin/env bash`) for bash-specific code.
- `grep` is ugrep (mostly GNU-compatible, `-P` works) and its warnings say
  `ugrep:`.
- GNU `dd` sizes are uppercase (`bs=1M`, not `bs=1m`).
- `sudo` needs a password, so it can't run non-interactively.
