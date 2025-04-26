set shell := ['zsh', '-cu']

os := os()
rebuild := if os == 'linux' { 'nixos-rebuild ' } else { if os == 'macos' { 'darwin-rebuild ' } else { error('Unsupported OS: ' + os) } }
rebuild_opts := if os == 'linux' { '' } else { '--impure ' }
sudo := if os == 'linux' { 'sudo ' } else { '' }
hostname := shell('hostname')
host_dir := shell('fd', quote(hostname), '~/git/dotfiles/hosts --type d --max-depth 1 -1')
host := if host_dir == '' { error("Couldn't find a flake matching hostname") } else { hostname }
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
[private]
rebuild prefix arg flake *opts:
    {{ if prefix == 'sudo' { sudo } else { '' } }}{{ rebuild }}{{ rebuild_opts }}{{ arg }} \
        --flake ~/git/dotfiles#'{{ flake }}' {{ opts }}

# Build and activate a specified flake or the host flake
[group('rebuild')]
switch flake=host *opts='': (rebuild 'sudo' 'switch' flake opts)

# Build a specified flake or the host flake, and make it the boot default
[group('rebuild')]
boot flake=host *opts='': (rebuild 'sudo' 'boot' flake opts)

# Build and activate a specified flake or the host flake, and revert on boot
[group('rebuild')]
test flake=host *opts='': (rebuild 'sudo' 'test' flake opts)

# Build a specified flake or the host flake
[group('rebuild')]
build flake=host *opts='': (rebuild '' 'build' flake opts)

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
check:
    nix flake check --log-lines 1000

# Format all files
[group('util')]
fmt:
    nix fmt

# Start a nix REPL with nixpkgs loaded
[group('util')]
repl:
    nix repl --file flake:nixpkgs

# Update the nixpkgs index
[group('util')]
index:
    nix-index

# Search for packages and package outputs
[group('util')]
search +args:
    nix-locate --top-level --regex {{ args }}

# Update flake lockfile for all or specified inputs
[group('util')]
update *args:
    nix flake update {{ args }}
