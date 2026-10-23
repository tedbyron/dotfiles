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
    # enableZshIntegration = true;

    casks = [
      "lunar"
      "nextdns-app"
      "rectangle"
      "spotify"
      "zen"
    ];

    masApps = {
      Bitwarden = 1352778147;
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
      "Ethernet"
      "Thunderbolt Bridge"
      "Wi-Fi"
    ];
  };

  launchd.daemons =
    let
      nix = "/nix/var/nix/profiles/default/bin/nix";
      nixJob = name: script: Hour: Minute: {
        command = pkgs.writeShellScript name ''
          set -eu
          ${script}
        '';
        serviceConfig = {
          StartCalendarInterval = [
            {
              Weekday = 0; # Sunday
              inherit Hour Minute;
            }
          ];
          StandardOutPath = "/var/log/${name}.log";
          StandardErrorPath = "/var/log/${name}.log";
        };
      };
    in
    {
      nix-gc = nixJob "nix-gc" ''
        ${nix} profile wipe-history --profile /nix/var/nix/profiles/system --older-than 30d
        ${nix} store gc
      '' 3 15;
      nix-optimise = nixJob "nix-optimise" "${nix} store optimise" 3 45;
    };
}
