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
  imports = [
    ./hardware-configuration.nix
    ../../users/${user}
  ];

  system.stateVersion = "24.11";
  swapDevices = [ { device = "/swap/swapfile"; } ];

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
    bluetooth.enable = true;
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

  services = {
    xserver.videoDrivers = [ "nvidia" ];

    btrfs.autoScrub = {
      enable = true;
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
  };
}
