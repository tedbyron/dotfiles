# dotfiles

<div float="left">
  <img src="../screenshots/screenshots/neovim.png" alt="neovim" width="49%" />
  <img src="../screenshots/screenshots/vscode.png" alt="vs code" width="49%" />
</div>

## Just

```just
[rebuild]
switch *opts         # Build and activate the host flake
boot *opts           # Build the host flake, and make it the boot default
test *opts           # Build and activate the host flake, and revert on boot
build *opts          # Build the host flake

[history]
rollback             # Rollback to the previous generation
history limit='10'   # List available generations
wipe-history days    # Delete generations older than input days

[util]
check                # Run all flake checks
format               # Format all files
repl                 # Start a nix REPL with nixpkgs loaded
index                # Update the nixpkgs index
search pattern *args # Search for top-level packages and package outputs
update *args         # Update flake lockfile for all or specified inputs
```

## MacOS

- Bootstrap

  ```sh
  xcode-select --install
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  git clone https://github.com/tedbyron/dotfiles.git ~/git/dotfiles --filter tree:0
  # Give terminal full disk access and restart
  nix run nix-darwin -- --flake ~/git/dotfiles#host switch

  fd '.*before-nix-darwin' /etc -X sudo rm
  ```

- Uninstall default apps

  ```sh
  mas uninstall \
    409203825   \ # Numbers
    408981434   \ # iMovie
    6826558836  \ # GarageBand
    409183694   \ # Keynote
    409201541   \ # Pages
  ```

- Disable tipsd

  ```sh
  sudo launchctl disable system/com.apple.tipsd
  ```

## NixOS

- Bootstrap

  - Boot to installer

    ```sh
    sudo -i
    ```

  - Partition and format

    <!-- TODO: disko -->

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

      mkdir /mnt
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
      mount -o compress=zstd,noatime,discard,subvol=nix \
        /dev/disk/by-label/nixos /mnt/nix
      mount -o noatime,discard,subvol=home \
        /dev/disk/by-label/nixos /mnt/home
      mount -o nodatacow,noatime,discard,subvol=swap \
        /dev/disk/by-label/swap /mnt/swap
      mount -o umask=077 /dev/disk/by-label/boot /mnt/boot

      dd if=/dev/zero of=/mnt/swap/swapfile bs=1MB
      chmod 0600 /mnt/swap/swapfile
      mkswap -L swap -U clear /mnt/swap/swapfile
      swapon /mnt/swap/swapfile
      ```

      </details>

  - <details><summary>Connect to wifi if necessary</summary>

    - `nmcli` (requires graphical installer)

      ```sh
      nmcli device wifi list
      nmcli device wifi connect SSID password PASSWORD
      ```

    - `wpa_cli`

      ```sh
      systemctl stop NetworkManager
      systemctl start wpa_supplicant
      wpa_cli
      add_network
      set_network 0 ssid SSID
      set_network 0 psk PASSWORD
      enable_network 0
      ```

    </details>

  - Generate config

    ```sh
    nixos-generate-config --root /mnt
    ```

  - <details><summary>Edit config</summary>

    ```nix
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
            options = defaultOpts ++ [ "nodatacow" ];
          };
        };
    }
    ```

    </details>

  - Install

    ```sh
    nixos-install
    mkdir /mnt/snapshots
    btrfs subvolume snapshot -r /mnt /mnt/snapshots/root-after-install
    nixos-enter --root /mnt -c 'passwd ted'
    reboot
    ```

  - Switch to flake

    ```sh
    # Reconnect to wifi if necessary
    nix run nixpkgs#git -- \
      clone https://github.com/tedbyron/dotfiles.git ~/git/dotfiles \
      --filter tree:0
    sudo nixos-rebuild --flake ~/git/dotfiles#host switch
    reboot
    ```

- VS Code

  - Preferences: configure runtime arguments

    ```json
    "password-store": "gnome-libsecret"
    ```

  - Preferences

    ```json
    "window.titleBarStyle": "native"
    ```

- Windows dual boot

  - Change hardware clock to UTC in registry
    `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation`

    |          key          |   value    |  type   |
    | :-------------------: | :--------: | :-----: |
    | `RealTimeIsUniversal` | `00000001` | `dword` |

    ```cmd
    reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
    ```

## Commands I'm going to forget about

- PCI display controllers

  ```sh
  nix shell nixpkgs#pciutils -c lspci -kd ::03xx
  ```

- EDID info

  ```sh
  fd edid /sys/devices/pci0000:00
  nix shell nixpkgs#read-edid -c parse-edid /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/drm/card2/card2-DP-4/edid
  ```

- OpenGL

  ```sh
  nvidia-settings --glxinfo
  nix shell nixpkgs#glxinfo -c glxinfo
  ```

- Vulkan

  ```sh
  nix shell nixpkgs#vulkan-tools -c vulkaninfo
  ```

- VA-API

  ```sh
  NVD_LOG=1 nix shell nixpkgs#libva-utils -c vainfo
  ```

- Gpg test key retrieval

  ```sh
  gpg --locate-keys --auto-key-locate clear,nodefault,wkd address@example.com
  ```

- Reinstall bootloader

  ```sh
  sudo nixos-rebuild --install-bootloader boot
  ```
