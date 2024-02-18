# Nix stuff

## Building linux binaries on darwin

<https://nixos.org/manual/nixpkgs/unstable/#sec-darwin-builder>

- daemon: `org.nixos.linux-builder`
- storage in `/var/lib/darwin-builder`
- `/etc/ssh/ssh_config.d/100-linux-builder.conf` creates SSH host-alias `linux-builder`
- `/etc/nix/machines` contains remote builder entry

```nix
# nix-darwin configuration.nix
{
  nix = {
    trusted-users = [ "@admin" ];
    linux-builder = {
      enable = true;
      # ephemeral = true;
      # maxJobs = 4;

      # config = {
      #   virtualisation = {
      #     cores = 6;

      #     darwin-builder = {
      #       diskSize = 32 * 1024;
      #       memorySize = 8 * 1024;
      #     };
      #   };
      # };
    };
  };
}
```

```sh
nix build \
  --impure \
  --expr '(with import <nixpkgs> { system = "aarch64-linux"; }; runCommand "foo" {} "uname -a > $out")'
cat result
```
