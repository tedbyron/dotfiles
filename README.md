# dotfiles

My dotfiles

# Installation

1. ```sh
   xcode-select --install
   ```

1. Install nix: <https://github.com/DeterminateSystems/nix-installer>.

1. ```sh
   nix-shell -p nixUnstable gh
   ```

1. ```sh
   gh repo clone tedbyron/dotfiles ~/dotfiles -- --filter tree:0 && cd ~/dotfiles
   ```

1. Build a config.

   - macOS:

     ```sh
     nix build .#darwinConfigurations.<CONFIG>.system
     ```
