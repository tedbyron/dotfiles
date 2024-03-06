# dotfiles

My dotfiles

<div float="left">
  <img src="../screenshots/screenshots/nvim.png" alt="neovim" width="49%" />
  <img src="../screenshots/screenshots/vscode.png" alt="vs code" width="49%" />
</div>

## Install

- Darwin

  ```sh
  xcode-select --install
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  git clone https://github.com/tedbyron/dotfiles ~/git/dotfiles --filter tree:0
  # give terminal full disk access and restart
  nix run nix-darwin -- switch --flake ~/git/dotfiles#<host>
  ```
