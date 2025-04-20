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
  git clone https://github.com/tedbyron/dotfiles.git ~/git/dotfiles --filter tree:0
  # Give terminal full disk access and restart
  nix run nix-darwin -- --flake ~/git/dotfiles#host --impure switch
  ```

- NixOS (btrfs)

  ```sh
  sudo -i

  # connect to wifi if no ethernet; nmcli requires graphical installer
  nmcli device wifi list
  nmcli device wifi connect BSSID password PASSWORD

  parted /dev/sdX -- mklabel gpt
  parted /dev/sdX -- mkpart root btrfs 512MiB -38GiB
  parted /dev/sdX -- mkpart swap btrfs -38GiB 100%
  parted /dev/sdX -- mkpart ESP fat32 1MiB 512MiB
  parted /dev/sdX -- set 3 esp on

  mkfs.btrfs -L nixos /dev/sdX1
  mkfs.btrfs -L swap /dev/sdX2
  mkfs.fat -F 32 -n boot /dev/sdX3

  mkdir -p /mnt/{nix,home,swap,boot}
  mount /dev/sdX1 /mnt
  btrfs subvolume create /mnt/root
  btrfs subvolume create /mnt/nix
  btrfs subvolume create /mnt/home
  btrfs subvolume create /mnt/swap
  umount /mnt

  mount -o noatime,discard,subvol=root /dev/sdX1 /mnt
  mount -o compress=zstd,noatime,discard,subvol=nix /dev/sdX1 /mnt/nix
  mount -o noatime,discard,subvol=home /dev/sdX1 /mnt/home
  mount -o noatime,discard,subvol=swap /dev/sdX2 /mnt/swap
  mount -o umask=077 /dev/sdX3 /mnt/boot

  btrfs filesystem mkswapfile --size 38g --uuid clear /mnt/swap/swapfile
  swapon /dev/sdX2

  nixos-generate-config --root /mnt
  # add mount options to config
  nixos-install
  nixos-enter --root /mnt -c 'passwd ted'

  nix-shell -p git
  git clone https://github.com/tedbyron/dotfiles.git ~/git/dotfiles --filter tree:0
  nixos-rebuild --experimental-features 'flakes' --flake ~/git/dotfiles#host switch
  systemctl kexec
  ```
