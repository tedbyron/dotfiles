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

  fonts.packages = [ self.outputs.packages.${system}.curlio-ttf ];
  security.pam.enableSudoTouchIdAuth = true;

  programs = {
    gnupg.agent.enable = true;
    zsh.enable = true;
  };

  environment = {
    etc."pam.d/sudo_local".text = ''
      # nix-darwin environment.etc."pam.d/sudo_local".text
      auth        optional        ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
      auth        sufficient      pam_tid.so
    '';

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
      nmap
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
      Bitwarden = 1352778147;
      NextDns = 1464122853;
      Xcode = 497799835;
    };

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
  };
}
