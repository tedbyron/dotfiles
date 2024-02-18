# dotfiles

My dotfiles

1. ```sh
   xcode-select --install
   ```

1. Install nix: <https://github.com/determinatesystems/nix-installer>.

1. ```sh
   nix-shell -p nixUnstable gh
   ```

1. ```sh
   gh repo clone tedbyron/dotfiles ~/dotfiles -- --filter tree:0 && cd ~/dotfiles
   ```

1. Build a config or switch to a config.

   - Build:

     ```sh
     nix build .#darwinConfigurations.gamma.system
     ```

   - Switch:

     ```sh
     nix run nix-darwin -- --flake .#darwinConfigurations.gamma.system
     ```
