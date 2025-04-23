{ pkgs, ... }:
{
  imports = [
    ./dock.nix
    ./system.nix
  ];

  security.pam.enableSudoTouchIdAuth = true;

  environment = {
    etc."pam.d/sudo_local".text = ''
      # nix-darwin environment.etc."pam.d/sudo_local".text
      auth        optional        ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
      auth        sufficient      pam_tid.so
    '';

    variables = {
      HOMEBREW_NO_ANALYTICS = "1";
      HOMEBREW_NO_ENV_HINTS = "1";
    };
  };

  homebrew = {
    enable = true;

    casks = [
      "firefox"
      "lunar"
      "mullvadvpn"
      "rectangle"
      "vlc"
    ];

    masApps = {
      Bitwarden = 1352778147;
      NextDns = 1464122853;
    };

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
  };

  networking = {
    wakeOnLan.enable = false;

    dns = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];

    # networksetup -listallnetworkservices
    knownNetworkServices = [
      "Thunderbolt Bridge"
      "Wi-Fi"
    ];
  };

  nix = {
    configureBuildUsers = true;
    settings.trusted-users = [ "@admin" ];
    useDaemon = true;

    gc.interval = [
      {
        Hour = 3;
        Minute = 15;
      }
    ];

    optimise.interval = [
      {
        Hour = 3;
        Minute = 45;
      }
    ];
  };
}
