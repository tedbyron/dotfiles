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
            files = "*.yml";
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
        pythonFiles = [ "bin/xrandr-to-modeline" ];
        shellFiles = [ "bin/cargo-install-update" ];
      in
      {
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
      "config/Microsoft.PowerShell_profile.ps1"
      "config/bat/*"
      "config/doom/*"
      "config/ghostty/themes/*"
      "config/ripgrep/*"
      "config/tmux/*"
      "config/zsh/*"
      "config/pam-gnupg"
      ".gitignore"
      "LICENSE"
      "flake.lock"
    ];
  };
}
