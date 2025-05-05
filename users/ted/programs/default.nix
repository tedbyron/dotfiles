{
  self,
  pkgs,
  unstable,
  lib,
  darwin,
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
      enable = true;
      settings = builtins.fromTOML (lib.ted.readConfig "alacritty/alacritty.toml");
    };

    bat = {
      enable = true;

      config = {
        style = "changes,numbers";
        theme = "gruvbox-material-dark";
      };

      themes.gruvbox-material-dark = {
        src = lib.ted.configPath "bat";
        file = "gruvbox-material-dark.tmTheme";
      };
    };

    direnv = {
      enable = true;
      config = builtins.fromTOML (lib.ted.readConfig "direnv/direnv.toml");
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;

      settings = {
        git_protocol = "https";
        editor = "nvim";
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
        extraConfig = builtins.fromTOML (lib.ted.readConfig "git/config") // {
          credential.helper = if darwin then "osxkeychain" else "${package}/bin/git-credential-libsecret";
        };
        ignores = lib.splitString "\n" (lib.ted.readConfig "git/ignore");
        lfs.enable = true;
      };

    go = {
      enable = true;
      # telemetry.mode = "off"; # TODO: 25.05
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
      enableZshIntegration = true;
    };

    pandoc.enable = true;

    ripgrep = {
      enable = true;
      arguments = lib.splitString "\n" (lib.ted.readConfig "ripgrep/ripgreprc");
    };

    spicetify =
      let
        spicePkgs = self.inputs.spicetify-nix.legacyPackages.${pkgs.system};
      in
      {
        enable = true;
        colorScheme = "gruvbox-material-dark";
        theme = spicePkgs.themes.dribbblish;
      };

    ssh.enable = true;

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = builtins.fromTOML (lib.ted.readConfig "starship.toml");
    };

    tealdeer = {
      enable = true;
      settings = builtins.fromTOML (lib.ted.readConfig "tealdeer/config.toml");
    };

    vscode = {
      enable = true;
      package = unstable.vscode;
    };

    yt-dlp.enable = true;
  };
}
