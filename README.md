# dotfiles

<div float="left">
  <img src="../screenshots/screenshots/neovim.png" alt="neovim" width="49%" />
  <img src="../screenshots/screenshots/vscode.png" alt="vs code" width="49%" />
</div>

## Bootstrap

- Darwin

  ```sh
  xcode-select --install
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  git clone https://github.com/tedbyron/dotfiles.git ~/git/dotfiles --filter tree:0
  # Give terminal full disk access and restart
  nix run nix-darwin -- switch --impure --flake ~/git/dotfiles#<host>
  ```

<!-- TODO: <https://wiki.nixos.org/wiki/NixOS_virtual_machines_on_macOS#linux-builder> -->
