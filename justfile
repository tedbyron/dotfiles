set quiet := true
set shell := ['zsh', '-cu']

os := os()
rebuild := if os == 'linux' { 'nixos-rebuild' } else if os == 'macos' { 'darwin-rebuild' } else { error('Unsupported OS: ' + os) }
sudo := if os == 'linux' { 'sudo' } else { '' }

alias b := build
alias c := check
alias f := format
alias h := history
alias s := search
alias u := update
alias up := update

[private]
default:
    just -ul --list-heading ''

#

[group('rebuild')]
[private]
rebuild prefix arg *opts:
    #!/usr/bin/env zsh
    set -euo pipefail
    h=$(hostname)
    if { fd -gqt d -d 1 $h ~/git/dotfiles/hosts } {
        {{ prefix }} {{ rebuild }} {{ arg }} --flake ~/git/dotfiles#$h {{ opts }}
    } else {
        echo "No config for host: $h"
        exit 1
    }

# Build and activate the host flake
[group('rebuild')]
switch *opts: (rebuild 'sudo' 'switch' opts)

# Build the host flake, and make it the boot default
[group('rebuild')]
[linux]
boot *opts: (rebuild 'sudo' 'boot' opts)

# Build and activate the host flake, and revert on boot
[group('rebuild')]
[linux]
test *opts: (rebuild 'sudo' 'test' opts)

# Build the host flake
[group('rebuild')]
build *opts: (rebuild '' 'build' opts)

#

# Rollback to the previous generation
[group('history')]
rollback:
    {{ sudo }} {{ rebuild }} --rollback

# List available generations
[group('history')]
history limit='10':
    #!/usr/bin/env zsh
    set -euo pipefail
    l={{ if limit == '0' { '+1' } else { limit } }}
    # TODO: actually get current gen instead of the most recent
    if [[ {{ os }} == linux ]] {
        g=$({{ rebuild }} list-generations | tail +2 | tac | tail -n $l |
            rg -w '([[:xdigit:]]{7})([[:xdigit:]]{33,})' -r '$1' |
            rg '\b {2,}' -r $'\t')
        column -tc $COLUMNS -s $'\t' -N Gen,Date,NixOS,Kernel,Rev,Spec \
            <<<"$(head -n -1 <<<$g)
    {{ CYAN }}${$(tail -1 <<<$g)/current}{{ NORMAL }}"
    } else {
        g=$({{ rebuild }} --list-generations | tail -n $l)
        print -aC 3 Gen Date ' ' ${=$(head -n -1 <<<$g)} \
            '{{ CYAN }}'${(@)$(tail -1 <<<$g)[1,3]}'{{ NORMAL }}'
    }

# Delete generations older than input days
[confirm]
[group('history')]
wipe-history days:
    {{ sudo }} nix profile wipe-history \
        --profile /nix/var/nix/profiles/system \
        --older-than {{ days }}d

#

# Run all flake checks
[group('util')]
check:
    #!/usr/bin/env zsh
    set -uo pipefail
    { e=$(unbuffer nix flake check --log-lines 0 ~/git/dotfiles# \
        >&1 >&3 1>/dev/null 3>&- |& tail -1)
    } 3>&1
    c=$?
    if (( c )) {
        d=$(rg -o '/nix/store/[0-9a-z]{32}-[-.+_?=0-9a-zA-Z]+.drv' <<<$e)
        if [[ -n $d ]] { nix log $d | delta --paging never }
    }
    exit $c

# Format all files
[group('util')]
format:
    nix fmt ~/git/dotfiles

# Start a nix REPL with nixpkgs loaded
[group('util')]
repl:
    nix repl -f flake:nixpkgs

# Update the nixpkgs index
[group('util')]
index:
    nix-index

# Search for top-level packages and package outputs
[group('util')]
search pattern *args:
    #!/usr/bin/env zsh
    set -euo pipefail
    o=$(nix-locate -rw --top-level '{{ pattern }}' {{ args }} | sort -b)
    r() rg --passthru -U $(rg '(.)' -r '$1\s*' <<<'{{ pattern }}')
    if [[ -z ${=o} ]] exit 0
    if [[ {{ os }} == linux ]] {
        rg --passthru -w ' {2,}' -r ' ' <<<$o |
        column -tc $COLUMNS -N Package,Size,Type,Path -W Path | r
    } else {
        print -aC 4 Package Size Type Path ${=o} | r
    }

# Update flake lockfile for all or specified inputs
[group('util')]
update *args:
    nix flake update {{ args }}
