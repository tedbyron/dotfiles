# dotfiles

<div float="left">
  <img src="../screenshots/screenshots/neovim.png" alt="neovim" width="49%" />
  <img src="../screenshots/screenshots/vscode.png" alt="vs code" width="49%" />
</div>

## Bootstrap

- Darwin

  ```sh
  xcode-select --install
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  # No determinate nix
  git clone https://github.com/tedbyron/dotfiles.git ~/git/dotfiles --filter tree:0
  # Give terminal full disk access and restart
  nix run nix-darwin -- --flake ~/git/dotfiles#host --impure switch
  ```

- NixOS

  - Boot to installer

    ```sh
    sudo -i
    ```

  - Partition and format

    - <details>
      <summary>btrfs</summary>

      ```sh
      lsblk
      parted /dev/nvmeXn1 -- mklabel gpt
      parted /dev/nvmeXn1 -- mkpart root btrfs 500MB -38GB
      parted /dev/nvmeXn1 -- mkpart swap btrfs -38GB 100%
      parted /dev/nvmeXn1 -- mkpart ESP fat32 1MB 500MB
      parted /dev/nvmeXn1 -- set 3 esp on

      mkfs.btrfs -L nixos /dev/nvmeXn1p1
      mkfs.btrfs -L swap /dev/nvmeXn1p2
      mkfs.fat -F 32 -n boot /dev/nvmeXn1p3

      mkdir -p /mnt
      mount /dev/nvmeXn1p1 /mnt
      btrfs subvolume create /mnt/root
      btrfs subvolume create /mnt/nix
      btrfs subvolume create /mnt/home
      umount /mnt

      mount /dev/nvmeXn1p2 /mnt
      btrfs subvolume create /mnt/swap
      umount /mnt

      mount -o noatime,discard,subvol=root /dev/disk/by-label/nixos /mnt
      mkdir /mnt/{nix,home,swap,boot}
      mount -o compress=zstd,noatime,discard,subvol=nix /dev/disk/by-label/nixos /mnt/nix
      mount -o noatime,discard,subvol=home /dev/disk/by-label/nixos /mnt/home
      mount -o noatime,discard,subvol=swap /dev/disk/by-label/swap /mnt/swap
      mount -o umask=077 /dev/disk/by-label/boot /mnt/boot

      dd if=/dev/zero of=/mnt/swap/swapfile bs=500MB
      mkswap -L swap -U clear /mnt/swap/swapfile
      swapon /mnt/swap/swapfile
      ```

      </details>

  - Connect to wifi if necessary

    - `nmcli` (requires graphical installer)

      ```sh
      nmcli device wifi list
      nmcli device wifi connect BSSID password PASSWORD
      ```

    - `wpa_cli`

      ```sh
      systemctl stop NetworkManager
      sudo systemctl start wpa_supplicant
      wpa_cli
      add_network
      set_network 0 ssid SSID
      set_network 0 psk PASSWORD
      enable_network 0
      ```

  - Generate config

    ```sh
    nixos-generate-config --root /mnt
    ```

  - <details><summary>Edit config</summary>

    ```nix
    # btrfs setup; check hardware-configuration.nix
    { config, lib, pgks, ... }: {
      swapDevices = [ { device = "/swap/swapfile"; } ];

      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      networking = {
        hostname = "teds-desktop";
        networkmanager.enable = true;
      };

      nix.settings.experimental-features = [
        "auto-allocate-uids"
        "flakes"
        "nix-command"
        "pipe-operators"
      ];

      users = {
        defaultUserShell = pkgs.zsh;

        users.ted = {
          description = "Teddy Byron";
          extraGroups = [ "networkmanager" "wheel" ];
          isNormalUser = true;
          uid = 1000;
        };
      };

      fileSystems =
        let defaultOpts = [ "noatime" "discard" ];
        in {
          "/".options = defaultOpts;
          "/nix".options = defaultOpts ++ [ "compress=zstd" ];
          "/home".options = defaultOpts;
          "/boot".neededForBoot = true;

          "/swap" = {
            neededForBoot = true;
            options = defaultOpts;
          };
        };
    }
    ```

    </details>

  - Install

    ```sh
    nixos-install
    mkdir /mnt/snapshots && btrfs subvolume snapshot -r /mnt /mnt/snapshots/root-after-install
    nixos-enter --root /mnt -c 'passwd ted'
    reboot
    ```

  - Switch to flake

    ```sh
    # Reconnect to wifi if necessary
    nix-shell -p git
    git clone https://github.com/tedbyron/dotfiles.git ~/git/dotfiles --filter tree:0
    sudo nixos-rebuild --flake ~/git/dotfiles#host switch
    reboot
    ```
