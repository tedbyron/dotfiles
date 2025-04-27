{
  self,
  config,
  pkgs,
  unstable,
  lib,
  ...
}:
{
  imports = [ ./firefox.nix ];

  console.useXkbConfig = true; # TODO: console colors
  environment.systemPackages = [ pkgs.unzip ];
  gtk.iconCache.enable = true;
  location.provider = "geoclue2";
  system.fsPackages = [ pkgs.bindfs ];
  # BUG: https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.Network-Manager-wait-online.enable = false;
  time.timeZone = "America/New_York";
  users.defaultUserShell = pkgs.zsh;
  xdg.portal.xdgOpenUsePortal = true;

  boot.loader.systemd-boot = {
    configurationLimit = lib.mkDefault 128;
    editor = lib.mkDefault false;
  };

  fileSystems =
    let
      mkRoBindfs = path: {
        device = path;
        fsType = "fuse.bindfs";

        options = [
          "ro"
          "resolve-symlinks"
          "x-gvfs-hide"
        ];
      };

      aggregated = pkgs.buildEnv {
        name = "system-fonts-and-icons";

        paths =
          config.fonts.packages
          ++ (with pkgs; [
            capitaine-cursors-themed
            gruvbox-plus-icons
          ]);

        pathsToLink = [
          "/share/fonts"
          "/share/icons"
        ];
      };
    in
    {
      "/usr/share/fonts" = mkRoBindfs "${aggregated}/share/fonts";
      "/usr/share/icons" = mkRoBindfs "${aggregated}/share/icons";
    };

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = [ self.inputs.apple-emoji-linux.outputs.packages.${pkgs.system}.default ];

    fontconfig.defaultFonts = {
      monospace = [ "Curlio" ];
      sansSerif = [ "Inter" ];
      serif = [ "Libre Baskerville" ];
      emoji = [ "Apple Color Emoji" ];
    };
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
    seahorse.enable = true;

    hyprland = {
      enable = true;
      package = unstable.hyprland;
      portalPackage = unstable.xdg-desktop-portal-hyprland;
      withUWSM = true;
      xwayland.enable = true;
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
    upower.enable = true;

    pipewire = {
      enable = true;
      pulse.enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };
    };

    resolved = {
      enable = true;
      fallbackDns = config.networking.nameservers;
    };
  };
}
