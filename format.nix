_: {
  programs = {
    deadnix.enable = true;
    just.enable = true;
    mix-format.enable = true;
    nixfmt.enable = true;
    ruff-check.enable = true;
    ruff-format.enable = true;
    shellcheck.enable = true;
    statix.enable = true;
    taplo.enable = true;

    prettier = {
      enable = true;

      settings = {
        proseWrap = "always";
        semi = false;
        singleQuote = true;
        trailingComma = "all";

        overrides = [
          {
            files = [ "*.jsonc" ];
            options.trailingComma = "none";
          }
          {
            files = [ "*.yml" ];
            options.singleQuote = false;
          }
        ];
      };
    };

    shfmt = {
      enable = true;
      indent_size = 4;
    };

    stylua = {
      enable = true;
      settings = builtins.fromTOML (builtins.readFile ./config/stylua.toml);
    };
  };

  settings = {
    formatter =
      let
        shellFiles = [ "bin/cargo-install-update" ];
        pythonFiles = [ "bin/xrandr-to-modeline" ];
      in
      {
        prettier.includes = [ "*.jsonc" ];
        ruff-check.includes = pythonFiles;
        ruff-format.includes = pythonFiles;
        shfmt.includes = shellFiles;

        shellcheck = {
          includes = shellFiles;
          options = [
            "--check-sourced"
            "--shell=bash"
          ];
        };

        taplo.includes = [
          "config/ghostty/config"
          "config/git/config"
          "config/tio/config"
        ];
      };

    excludes = [
      "bin/qr"
      "bin/termcolors"
      "config/**/ignore"
      "config/bat/*"
      "config/doom/*"
      "config/ghostty/themes/*"
      "config/gtk-*/*"
      "config/ripgrep/*"
      "config/tmux/*"
      "config/zsh/*"
      "config/.gtkrc-2.0"
      "config/Microsoft.PowerShell_profile.ps1"
      "config/pam-gnupg"
      ".gitignore"
      "LICENSE"
      "flake.lock"
    ];
  };
}
