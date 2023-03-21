<div align="center">
  <h1><code>dotfiles</code></h1>

  <p>
    <strong>My dotfiles</strong>
  </p>
</div>

# Installation

- Install nix

  ```
  sh <(curl -L https://nixos.org/nix/install) --daemon
  ```

- Clone dotfiles

  ```
  nix-shell -p nixUnstable gh
  gh repo clone tedbyron/dotfiles ~/dotfiles -- --depth 1
  ```

- Build a configuration from the flake

  ```
  cd ~/dotfiles
  nix build #darwinConfigurations.teds-mac.system \
    --auto-optimise-store \
    --experimental-features 'nix-command flakes'
  ```

# Troubleshooting

- SSL error

  <https://nixos.org/manual/nix/stable/installation/env-variables.html#nix_ssl_cert_file-with-macos-and-the-nix-daemon>
