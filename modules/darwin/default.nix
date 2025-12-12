{ pkgs, ... }:
{
  imports = [ ./system.nix ];

  security.pam.services.sudo_local.touchIdAuth = true;
  system.primaryUser = "ted";

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
      "mullvad-vpn"
      "rectangle"
      "spotify"
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
    settings.trusted-users = [ "@admin" ];

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
