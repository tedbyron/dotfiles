{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../users/ted
  ];

  environment.systemPackages = [ pkgs.qbittorrent ];
  system.stateVersion = "24.11";
  swapDevices = [ { device = "/swap/swapfile"; } ];

  networking = {
    hostName = baseNameOf (toString ./.);
    networkmanager.enable = true;
  };

  boot = {
    blacklistedKernelModules = [ "nouveau" ];
    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
    initrd.kernelModules = [ "nvidia" ];

    loader = {
      efi.canTouchEfiVariables = true;

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
      open = true;
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
