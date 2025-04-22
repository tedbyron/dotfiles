{
  inputs,
  pkgs,
  unstable,
  ...
}:
{
  console.useXkbConfig = true; # TODO: console colors
  gtk.iconCache.enable = true;
  location.provider = "geoclue2";
  # BUG: https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.Network-Manager-wait-online.enable = false;
  time.timeZone = "America/New_York";
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
    pciutils
    qt5.qtwayland
    qt6.qtwayland
    unzip
  ];

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
    zsh.enable = true;

    hyprland = {
      enable = true;
      package = unstable.hyprland;
      portalPackage = unstable.xdg-desktop-portal-hyprland;
      withUWSM = true;
    };

    uwsm = {
      enable = true;
      waylandCompositors.hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/Hyprland";
      };
    };
  };

  security = {
    rtkit.enable = true;

    pam.services.login = {
      enableGnomeKeyring = true;
      gnupg.enable = true;
    };
  };

  # TODO: https://wiki.nixos.org/wiki/NextDNS
  services = {
    auto-cpufreq.enable = true;
    fwupd.enable = true;
    geoclue2.enable = true;
    playerctld.enable = true;
    redshift.enable = true; # TODO: cfg
    resolved.enable = true;
    upower.enable = true;

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
    extraPortals = [ unstable.xdg-desktop-portal-hyprland ];
    wlr.enable = true;
    xdgOpenUsePortal = true;
  };
}
