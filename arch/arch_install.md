# Arch Install Instructions

## Resources

-   [Arch wiki installation guide](https://wiki.archlinux.org/index.php/installation_guide)

## Pre-installation

-   Verify boot mode for EFI
    ```sh
    ls /sys/firmware/efi/efivars
    ```
-   Connect to WiFi
    ```sh
    wifi-menu
    ```
-   Update system clock
    ```sh
    timedatectl set-ntp true
    ```
-   Partition devices
    ```sh
    lsblk
    cgdisk /dev/sdx  # EFI system: ef00, linux filesystem: 8300, linux swap: 8200
    ```
-   Format partitions
    ```sh
    mkfs.fat -F32 /dev/sdxY  # ESP requires FAT32
    mkfs.ext4 /dev/sdxY      # linux filesystem
    ```
-   Setup swap
    ```sh
    mkswap /dev/sdxY
    swapon /dev/sdxY
    ```
-   Mount partitions
    ```sh
    mount /dev/sdxY /mnt
    mkdir /mnt/boot
    mount /dev/sdxY /mnt/boot  # mount ESP to /boot
    ```

## Installation

-   Install base packages
    ```sh
    pacstrap /mnt base
    ```

## Config

-   Generate fstab
    ```sh
    genfstab -U /mnt >> /mnt/etc/fstab
    ```
-   Compare the
    ```sh
    lsblk -o name,label,uuid
    ```
-   Change root into new system
    ```sh
    arch-chroot /mnt
    ```
-   Set time zone
    ```sh
    ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
    hwclock --systohc
    ```
-   Install important stuff
    ```sh
    pacman -S sudo wpa_supplicant dialog vim
              intel-ucode  # microcode for intel processors
    ```
-   Set locale
    ```sh
    vim /etc/locale.gen  # en_US.UTF-8 UTF-8
    locale-gen

    vim /etc/locale.conf
    LANG=en_US.UTF-8
    ```
-   Network config
    ```sh
    touch /etc/hostname
    echo "hostname" > /etc/hostname
    vim /etc/hosts

        127.0.0.1       localhost
        ::1             localhost
        127.0.1.1       hostname.localdomain hostname
    ```
-   Set root password
    ```sh
    passwd
    ```
-   Install and configure bootloader
    ```sh
    bootctl --path=/boot install
    vim /boot/loader/loader.conf

        timeout         3
        console-mode    auto
        default         arch
        editor          no

    vim /boot/loader/entries/arch.conf

        title       Arch Linux
        linux       /vmlinuz-linux
        initrd      /intel-ucode.img
        initrd      /initramfs-linux.img
        options     root=PARTUUID=<FS PARTUUID> rw resume=<SWAP PARTUUID>
                    # to get block PARTUUID:
                    # lsblk -o name,label,partuuid
    ```

## Post-config

-   Exit mounted partition
    ```sh
    exit
    ```
-   Unmount partitions
    ```sh
    umount -R /mnt
    ```
-   Reboot
    ```sh
    reboot
    ```

## New system

-   Login as root
-   Do important stuff
    ```sh
    pacman -S terminus-font

    vim /etc/vconsole.conf

        FONT=ter-v18n

    vim /etc/pacman.conf

        CleanMethod = KeepCurrent
        Color
    ```
-   Connect to Wifi
    ```sh
    wifi-menu
    ```
-   Enable automatic wifi connection
    ```sh
    # shutdown interface
    ip link set <INTERFACE> down

    # enable and start the service
    systemctl enable --now netctl-auto@<INTERFACE>.service

    # if that fails, check for other services using the interface
    systemctl --type=service
    ```
-   Set a sudo group
    ```sh
    visudo

        %wheel ALL=(ALL) ALL
    ```
-   Create new user
    ```sh
    useradd -m -g wheel user
    passwd user
    ```
-   Login as new user
    ```sh
    exit
    ```

## [AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository)

[yay](https://github.com/Jguer/yay)
```sh
pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay/
```
