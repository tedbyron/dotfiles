set shell := ['zsh', '-cu']

os := os()
rebuild := if os == 'linux' { 'nixos-rebuild ' } else { if os == 'macos' { 'darwin-rebuild ' } else { error('Unsupported OS: ' + os) } }
rebuild-opts := if os == 'linux' { '' } else { '--impure ' }
sudo := if os == 'linux' { 'sudo ' } else { '' }
hostname := shell('hostname')
host-dir := shell('fd', quote(hostname), '~/git/dotfiles/hosts -td -d1 -1')
host := if host-dir == '' { error("Couldn't find a flake matching hostname") } else { hostname }

alias c := check
alias f := fmt
alias h := history
alias s := search
alias up := update

[private]
@default:
    just -ul --list-heading ''

#

[group('rebuild')]
[private]
rebuild prefix arg flake *opts:
    {{ if prefix == 'sudo' { sudo } else { '' } }}{{ rebuild }}{{ arg }} \
        --flake ~/git/dotfiles#'{{ flake }}' {{ rebuild-opts }}{{ opts }}

# Build and activate a specified flake or the host flake
[group('rebuild')]
switch flake=host *opts='': (rebuild 'sudo' 'switch' flake opts)

# Build a specified flake or the host flake, and make it the boot default
[group('rebuild')]
[linux]
boot flake=host *opts='': (rebuild 'sudo' 'boot' flake opts)

# Build and activate a specified flake or the host flake, and revert on boot
[group('rebuild')]
[linux]
test flake=host *opts='': (rebuild 'sudo' 'test' flake opts)

# Build a specified flake or the host flake
[group('rebuild')]
build flake=host *opts='': (rebuild '' 'build' flake opts)

# Rollback to the previous generation
[group('rebuild')]
rollback:
    {{ sudo }}{{ rebuild }} --rollback

#

# List available generations
[group('history')]
history limit='10':
    #!/usr/bin/env nix
    #!nix shell nixpkgs#coreutils nixpkgs#gnused nixpkgs#unixtools.column
    #!nix -c zsh
    set -euo pipefail
    limit='{{ if limit == '0' { '+1' } else { limit } }}'
    if [[ {{ os }} == linux ]] {
        ({{ rebuild }}list-generations \
            | tail +2 | tac | tail -n $limit) \
            | sed -re 's/\b([[:xdigit:]]{7})([[:xdigit:]]{33,})\b/\1/g' \
                -e 's/[[:space:]]{2,}/\t/g' \
            | column -ts $'\t' -N 'Gen,Date,NixOS,Kernel,Rev,Spec'
    } else {
        {{ rebuild }}--list-generations | tail -n $limit
    }

# Delete generations older than input days
[confirm]
[group('history')]
wipe-history days:
    {{ sudo }}nix profile wipe-history \
        --profile /nix/var/nix/profiles/system \
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
    nix repl -f flake:nixpkgs

# Update the nixpkgs index
[group('util')]
index:
    nix-index

# Search for packages and package outputs
[group('util')]
search +args:
    nix-locate -rw --top-level {{ args }}

# Update flake lockfile for all or specified inputs
[group('util')]
update *args:
    nix flake update {{ args }}
