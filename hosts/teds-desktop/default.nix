{
  config,
  pkgs,
  ...
}:
let
  name = baseNameOf (toString ./.);
  user = "ted";
in
{
  imports = [ ../../users/${user} ];

  security.rtkit.enable = true;
  swapDevices = [ "/swap/swapfile" ];
  system.stateVersion = "24.11";
  time.timeZone = "America/New_York";

  networking = {
    hostName = name;
    networkmanager.enable = true;
  };

  home-manager.users.${user}.home.packages = with pkgs; [
    discord
    qbittorrent
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fileSystems =
    let
      defaultOpts = [
        "noatime"
        "discard"
      ];
    in
    {
      "/".options = defaultOpts;
      "/nix".options = defaultOpts ++ [ "compress=zstd" ];
      "/home".options = defaultOpts;
      "/swap".options = defaultOpts;
    };

  hardware = {
    graphics.enable = true;

    display = {
      # TODO: https://nixos.org/manual/nixos/stable/#module-hardware-display
      # edid.modelines = {
      #   "XG27AQ_60" = "";
      #   "XG27AQ_120" = "";
      # };

      # outputs = {
      #   "DP-1".edid = "XG27AQ_120.bin";
      #   "DP-2".edid = "XG27AQ_60.bin";
      # };
    };

    nvidia = {
      modesetting.enable = true;
      # powerManagement.enable = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
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

  services = {
    btrfs.autoScrub = {
      enable = true;
      interval = "daily";
      fileSystems = [ "/" ];
    };

    pipewire = {
      enable = true;
      pulse.enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };

      wireplumber.extraConfig.bluetoothEnhancements = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;

          "bluez5.roles" = [
            "hsp_hs"
            "hsp_ag"
            "hfp_hf"
            "hfp_ag"
          ];
        };
      };
    };

    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };
}
