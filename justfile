set shell := ['zsh', '-cu']

os := os()
rebuild := if os == 'linux' { 'nixos-rebuild ' } else { if os == 'macos' { 'darwin-rebuild ' } else { error('Unsupported OS: ' + os) } }
rebuild-opts := if os == 'linux' { '' } else { '--impure ' }
sudo := if os == 'linux' { 'sudo ' } else { '' }
profile := '/nix/var/nix/profiles/system'

alias c := check
alias f := fmt
alias h := history
alias s := search
alias up := update

[private]
@default:
    just --list --unsorted --list-heading ''

#

[group('rebuild')]
_rebuild arg flake *opts:
    {{ sudo }}{{ rebuild }}{{ rebuild-opts }}{{ arg }} \
        --flake ~/git/dotfiles#'{{ flake }}' {{ opts }}

# Build and activate the specified flake
[group('rebuild')]
switch flake *opts: (_rebuild 'switch' flake opts)

# Build the specified flake and make it the boot default
[group('rebuild')]
boot flake *opts: (_rebuild 'boot' flake opts)

# Build and activate the specified flake, and revert on boot
[group('rebuild')]
test flake *opts: (_rebuild 'test' flake opts)

# Build the specified flake
[group('rebuild')]
build flake *opts: (_rebuild 'build' flake opts)

#

# List available generations
[group('history')]
history limit='10':
    {{ rebuild }}list-generations \
        | tee >(tail +2 | tac{{ if limit == '0' { '' } else { ' | tail -' + limit } }}) \
        | head -1

# Delete generations older than input days
[confirm]
[group('history')]
wipe-history days:
    {{ sudo }}nix profile wipe-history \
        --profile '{{ profile }}' \
        --older-than '{{ days }}'d

#

# Run all flake checks
[group('util')]
check *opts:
    nix flake check --log-lines 1000 {{ opts }}

# Format all files
[group('util')]
fmt *opts:
    nix fmt {{ opts }}

# Start a nix REPL with nixpkgs loaded
[group('util')]
repl *opts:
    nix repl --file flake:nixpkgs {{ opts }}

# Update the nixpkgs index
[group('util')]
index *opts:
    nix-index {{ opts }}

# Search for packages and package outputs
[group('util')]
search +args:
    nix-locate --top-level --regex {{ args }}

# Update flake lockfile for all or specified inputs
[group('util')]
update *args:
    nix flake update {{ args }}
