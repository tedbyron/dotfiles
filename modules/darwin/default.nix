{
  self,
  pkgs,
  system,
  ...
}:
{
  imports = [
    ./dock.nix
    ./nix.nix
    ./system.nix
  ];

  security.pam.enableSudoTouchIdAuth = true;

  programs = {
    gnupg.agent.enable = true;
    zsh.enable = true;
  };

  environment = {
    shells = with pkgs; [
      bashInteractive
      zsh
    ];

    systemPackages = with pkgs; [
      binutils
      coreutils
      curl
      diffutils
      findutils
      gawk
      gnugrep
      gnused
      groff
      less
      python3
    ];

    variables = {
      HOMEBREW_NO_ANALYTICS = "1";
      HOMEBREW_NO_ENV_HINTS = "1";
      LANG = "en_US.UTF-8";
    };
  };

  homebrew = {
    enable = true;

    casks = [
      "firefox"
      "mullvadvpn"
      "rectangle"
      "vlc"
    ];

    masApps = {
      NextDns = 1464122853;
      Bitwarden = 1352778147;
    };

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
  };

  fonts = {
    fontDir.enable = true;
    fonts = [ self.outputs.packages.${system}.curlio-ttf ];
  };
}
