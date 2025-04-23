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
      timeout = 5;

      systemd-boot = {
        enable = true;
        configurationLimit = 64;
        editor = false;

        # map -c; ls HD1b:\EFI
        edk2-uefi-shell = {
          enable = false;
          sortKey = "z_edk2";
        };

        memtest86 = {
          enable = true;
          sortKey = "y_memtest86";
        };

        windows.windows = {
          title = "Windows";
          efiDeviceHandle = "HD1b";
          sortKey = "m_windows";
        };
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
