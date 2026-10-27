# Project instructions

If a repository has an `AGENTS.md` file, follow it as the project's instructions
instead of `CLAUDE.md`.

## Git

Never add a `Co-Authored-By` trailer or any other AI attribution to commit
messages or pull requests.

## Shell environment

Prefer `rg` (ripgrep) over `grep` for searching files: it's recursive by
default, respects `.gitignore`, and filters by type (`rg -t nix pattern`) or
glob (`rg -g '*.nix' pattern`). Keep `grep` for filtering piped output.

### Windows

The shell is PowerShell 7+ (`pwsh`), not Windows PowerShell 5.1 or `cmd.exe`.
Use PowerShell cmdlets and syntax; GNU coreutils aren't on `PATH`, but `rg` is.

### macOS and Linux

Coreutils and common command-line tools on `PATH` (`ls`, `stat`, `date`, `dd`,
`sed`, `grep`, `awk`, `find`, `xargs`, etc.) are the GNU versions from nixpkgs,
including on macOS. Use GNU flags and syntax, not BSD.

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
