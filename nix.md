# Nix stuff

## Shell script shebang interpreter

<https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix.html?highlight=shebang#shebang-interpreter>.

```sh
#!/usr/bin/env nix
#!nix shell nixpkgs#bash nixpkgs#hello nixpkgs#cowsay --command bash

hello | cowsay
```

```sh
#!/usr/bin/env nix
#!nix shell --impure --expr ``
#!nix with (import (builtins.getFlake "nixpkgs") {});
#!nix terraform.withPlugins (plugins: [ plugins.openstack ])
#!nix ``
#!nix --command bash

terraform "$@"
```

````sh
#!/usr/bin/env nix
//!```cargo
//![dependencies]
//!time = "0.1.25"
//!```
/*
#!nix shell nixpkgs#rustc nixpkgs#rust-script nixpkgs#cargo --command rust-script
*/

fn main() {
    for argument in std::env::args().skip(1) {
        println!("{}", argument);
    };
    println!("{}", std::env::var("HOME").expect(""));
    println!("{}", time::now().rfc822z());
}

// vim: ft=rust
````

## Linux binaries in darwin

Uses `darwin.linux-builder` to make a VM remote builder.
<https://nixos.org/manual/nixpkgs/unstable/#sec-darwin-builder>.

- daemon: `org.nixos.linux-builder`
- storage in `/var/lib/darwin-builder`
- `/etc/ssh/ssh_config.d/100-linux-builder.conf` creates SSH host-alias `linux-builder`
- `/etc/nix/machines` contains remote builder entry

```nix
# nix-darwin configuration.nix
{
  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    maxJobs = 4;

    config.virtualisation = {
      cores = 6;

      darwin-builder = {
        diskSize = 32 * 1024;
        memorySize = 8 * 1024;
      };
    };
  };
}
```

```sh
nix build --impure --expr <<EOF
(with import <nixpkgs> { system = "aarch64-linux"; };
  runCommand "foo" {} ''
    uname -a > $out
  '')
EOF
```
