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

  environment.sessionVariables.LD_LIBRARY_PATH = "/run/opengl-driver/lib";
  home-manager.users.${user}.home.packages = [ pkgs.qbittorrent ];
  system.stateVersion = "24.11";
  swapDevices = [ { device = "/swap/swapfile"; } ];

  networking = {
    hostName = name;
    networkmanager.enable = true;
  };

  boot = {
    blacklistedKernelModules = [ "nouveau" ];

    loader = {
      efi.canTouchEfiVariables = true;
      timeout = null;

      systemd-boot = {
        enable = true;
        editor = false;
        consoleMode = "auto";

        edk2-uefi-shell = {
          enable = true;
          sortKey = "z_edk2";
        };

        memtest86 = {
          enable = true;
          sortKey = "o_memtest86";
        };

        # windows.windows = {

        # };
      };
    };
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
      "/boot".neededForBoot = true;

      "/swap" = {
        neededForBoot = true;
        options = defaultOpts ++ [ "nodatacow" ];
      };
    };

  hardware = {
    bluetooth.enable = true;
    graphics.enable = true;

    nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      powerManagement.enable = true;
    };
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];

    btrfs.autoScrub = {
      enable = true;
      fileSystems = [ "/" ];
    };

    pipewire.wireplumber.extraConfig.bluetooth-enhancements = {
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
}
