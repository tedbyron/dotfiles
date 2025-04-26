# dotfiles

<div float="left">
  <img src="../screenshots/screenshots/neovim.png" alt="neovim" width="49%" />
  <img src="../screenshots/screenshots/vscode.png" alt="vs code" width="49%" />
</div>

## Just

```console
[rebuild]
switch flake *opts # Build and activate the specified flake
boot flake *opts   # Build the specified flake and make it the boot default
test flake *opts   # Build and activate the specified flake, and revert on boot
build flake *opts  # Build the specified flake

[history]
history limit='10' # List available generations
h limit='10'       # alias for `history`
wipe-history days  # Delete generations older than input days

[util]
check *opts        # Run all flake checks
c *opts            # alias for `check`
fmt *opts          # Format all files
f *opts            # alias for `fmt`
repl *opts         # Start a nix REPL with nixpkgs loaded
index *opts        # Update the nixpkgs index
search +args       # Search for packages and package outputs
s +args            # alias for `search`
update *args       # Update flake lockfile for all or specified inputs
up *args           # alias for `update`
```

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

## NixOS

- <details><summary>VS Code</summary>

  - Preferences: configure runtime arguments

    ```json
    "password-store": "gnome-libsecret"
    ```

  </details>

- <details><summary>Windows dual boot</summary>

  - Change hardware clock to UTC in registry
    `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation`

    |          key          |   value    |  type   |
    | :-------------------: | :--------: | :-----: |
    | `RealTimeIsUniversal` | `00000001` | `dword` |

    ```cmd
    reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
    ```

  </details>

## Commands I'm going to forget about

- <details><summary>PCI display controllers</summary>

  ```sh
  nix shell nixpkgs#pciutils -c lspci -kd ::03xx
  ```

  </details>

- <details><summary>EDID info</summary>

  ```sh
  fd edid /sys/devices/pci0000:00
  nix shell nixpkgs#read-edid -c parse-edid /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/drm/card2/card2-DP-4/edid
  ```

  </details>

- <details><summary>OpenGL</summary>

  ```sh
  nvidia-settings --glxinfo
  nix shell nixpkgs#glxinfo -c glxinfo
  ```

  </details>

- <details><summary>Vulkan</summary>

  ```sh
  nix shell nixpkgs#vulkan-tools -c vulkaninfo
  ```

  </details>

- <details><summary>VA-API</summary>

  ```sh
  NVD_LOG=1 nix shell nixpkgs#libva-utils -c vainfo
  ```

  </details>
