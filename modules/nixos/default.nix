{
  inputs,
  pkgs,
  ...
}:
{
  console.useXkbConfig = true; # TODO: console colors
  gtk.iconCache.enable = true;
  location.provider = "geoclue2";
  security.rtkit.enable = true;
  # BUG: https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.Network-Manager-wait-online.enable = false;
  time.timeZone = "America/New_York";
  users.defaultUserShell = pkgs.zsh;

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      pciutils
      qt5.qtwayland
      qt6.qtwayland
      unzip
      wget
    ];
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  programs = {
    dconf.enable = true;
    firefox = import ./firefox.nix { inherit pkgs; };
    hyprland.enable = true;
    zsh.enable = true;
  };

  # TODO: https://wiki.nixos.org/wiki/NextDNS
  services = {
    auto-cpufreq.enable = true;
    fwupd.enable = true;
    geoclue2.enable = true;
    playerctld.enable = true;
    redshift.enable = true;
    resolved.enable = true;

    pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };
    };

    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    xdgOpenUsePortal = true;
  };
}
