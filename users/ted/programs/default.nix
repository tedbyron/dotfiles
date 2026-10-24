{
  pkgs,
  lib,
  darwin,
  unstable,
  ...
}:
{
  imports = [
    ./fzf.nix
    ./ghostty.nix
    ./neovim.nix
    ./tmux.nix
    ./wofi.nix
    ./zsh.nix
  ];

  programs = {
    alacritty = {
      enable = false;
      settings = fromTOML (lib.ted.readConfig "alacritty/alacritty.toml");
    };

    bat = {
      enable = true;

      config = {
        style = "changes,numbers";
        theme = "gruvbox-material-dark";
      };

      themes.gruvbox-material-dark = {
        src = lib.ted.configPath "bat/themes";
        file = "gruvbox-material-dark.tmTheme";
      };
    };

    direnv = {
      enable = true;
      config = fromTOML (lib.ted.readConfig "direnv/direnv.toml");
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;

      settings = {
        git_protocol = "https";
        editor = "nvim";
        telemetry = "disabled";
        color_labels = "enabled";
        pager = "delta";
        aliases = {
          prco = "pr checkout";
          open = "repo view --web";
        };
      };
    };

    git =
      let
        package = if darwin then pkgs.git else pkgs.git.override { withLibsecret = true; };
      in
      {
        enable = true;
        inherit package;
        # delta configured in .gitconfig and installed as a user package
        ignores = lib.splitString "\n" (lib.ted.readConfig "git/ignore");
        lfs.enable = true;

        settings = fromTOML (lib.ted.readConfig "git/config") // {
          credential.helper = if darwin then "osxkeychain" else "${package}/bin/git-credential-libsecret";
        };
      };

    go = {
      enable = true;
      telemetry.mode = "off";
    };

    gpg = {
      enable = true; # TODO: gpg signing keys

      settings = {
        default-key = "0BE1310591ECE7CF";
        no-greeting = true;
        keyid-format = "long";
        with-fingerprint = true;
        with-keygrip = true;
      };
    };

    # jujutsu
    # keychain

    hyprlock = {
      enable = false; # TODO
    };

    lazygit = {
      enable = true;
      settings = lib.ted.fromYAML (lib.ted.readConfig "lazygit/config.yml");
    };

    nix-index = {
      enable = true;
      package = unstable.nix-index; # 0.1.10 can't parse cache.nixos.org listings
      enableZshIntegration = true;
    };

    pandoc.enable = true;

    ripgrep = {
      enable = true;
      arguments = lib.splitString "\n" (lib.ted.readConfig "ripgrep/ripgreprc");
    };

    # UseKeychain needs Apple's /usr/bin/ssh
    ssh = {
      enable = darwin;
      enableDefaultConfig = false;
      settings."*" = {
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = fromTOML (lib.ted.readConfig "starship.toml");
    };

    tealdeer = {
      enable = true;
      settings = fromTOML (lib.ted.readConfig "tealdeer/config.toml");
    };

    vscode.enable = true;
    yt-dlp.enable = true;
  };
}
