# Arch Linux ARM

Steps to setup an Arch Linux ARM (aarch64) for 
an M1 VMWare Fusion virtual machine.

### Pre-installation

Download the ISO and boot up a live environment.  
Press `Ctrl-C` to go to a system prompt for manual installation.  

<https://archboot.com>  
archboot-2025.12.31-xxxxxxxx-aarch64-ARCH-local-aarch64.iso

Enable networking.

```
# systemctl restart systemd-networkd
# systemctl restart systemd-resolved
```

Verify internet connectivity.

```
# ip link show
# ip addr show
# ping -c 4 8.8.8.8
# ping -c 4 mirror.archlinuxarm.org
```

Verify synchronized clock.

```
# timedatectl
```

Partition the disks.

Identify the block device such as /dev/nvme0n1.

```
# lsblk
```

Run partitioning tool.  
Choose gpt when prompted. (GUID Partition Table)

```
# cfdisk /dev/nvme0n1
```

Use the following partition scheme.

| Partition | Size  | Type                |
|-----------|------:|---------------------|
| nvme0n1p1 | 2048M | EFI System          |
| nvme0n1p2 | rest  | Linux Filesystem    |

Format the partitions.

```
# mkfs.fat -F32 /dev/nvme0n1p1
# mkfs.btrfs -L ARCH /dev/nvme0n1p2
```

Create the btrfs subvolumes.

```
# mount /dev/nvme0n1p2 /mnt

# btrfs subvolume create /mnt/@
# btrfs subvolume create /mnt/@home

# umount -R /mnt
```

Mount the file systems.

```
# mount -o subvol=@,compress=zstd,noatime /dev/nvme0n1p2 /mnt

# mkdir -p /mnt/home
# mount -o subvol=@home,compress=zstd,noatime /dev/nvme0n1p2 /mnt/home

# mkdir -p /mnt/boot
# mount /dev/nvme0n1p1 /mnt/boot
```

### Installation

Install base system to root directory.

```
# pacstrap /mnt base \
                linux \
                linux-firmware \
                device-mapper \
                btrfs-progs \
                dosfstools \
                iptables-nft \
                terminus-font \
                nano \
                sudo \
                polkit
```

Generate filesystem table.

```
# genfstab -U /mnt >> /mnt/etc/fstab
```

`chroot` into the new operating system.

```
# arch-chroot /mnt
```

### Configuration

Set up time.

```
# ln -sf /usr/share/zoneinfo/Asia/Singapore /etc/localtime
# hwclock --systohc
```

Set up localization.

```
# nano /etc/locale.gen
    en_US.UTF-8 UTF-8
# locale-gen

# echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

Set up virtual console.

```
# nano /etc/vconsole.conf
    KEYMAP=us
    FONT=ter-v16n
```

Set up networking.

```
# echo "vm-alarm-hyprland" > /etc/hostname

# pacman -S networkmanager
# systemctl enable NetworkManager
```

Set up package management.

```
# pacman -S pacman-contrib
# systemctl enable paccache.timer
```

Set up a boot loader.

```
# bootctl --esp-path=/boot install

-- Use filenames found in /boot
-- (e.g. /Image and /initramfs-linux.img).
# ls -l /boot

-- Extract the PARTUUID of the device.
# blkid /dev/nvme0n1p2

# nano /boot/loader/entries/arch.conf
    title   Arch Linux ARM
    linux   /Image
    initrd  /initramfs-linux.img
    options root=PARTUUID=<PARTUUID-of-p2> rootfstype=btrfs rw rootflags=noatime,compress=zstd,subvol=@ quiet splash loglevel=0 rd.udev.log_level=0

# nano /boot/loader/loader.conf
    default arch
    timeout 0
    editor  0
```

Set up a splash screen.

```
# pacman -S plymouth

-- Edit HOOKS in /etc/mkinitcpio.conf
-- and ensure plymouth is after systemd and before filesystems
# nano /etc/mkinitcpio.conf
    MODULES=(btrfs vfat crc32c)
    HOOKS=(base systemd autodetect modconf keyboard sd-vconsole block plymouth filesystems fsck)

# plymouth-set-default-theme -R spinfinity

-- This is redundant.
-- plymouth-set-default-theme -R <theme> calls mkinitcpio already.
-- # mkinitcpio -P
```

Set up root account. 

```
# passwd
```

Set up a user account.

```
# useradd -m -G wheel -u 1000 -s /bin/bash mcdm -c "Mark Menchavez"
# passwd mcdm

# EDITOR=nano visudo
    %wheel ALL=(ALL:ALL) ALL
```

Reboot.

```
# exit
# umount -R /mnt
# reboot
```

### Post Installation

Set up timezone and clock synchronization.

```
$ sudo timedatectl set-local-rtc 0
$ sudo timedatectl set-timezone Asia/Singapore
$ sudo timedatectl set-ntp true
```

Enable swapfile.

```
$ sudo truncate -s 0 /swapfile
$ sudo chattr +C /swapfile
$ sudo btrfs filesystem mkswapfile --size 8G /swapfile
$ sudo swapon /swapfile
$ sudo nano /etc/fstab
    /swapfile none swap defaults 0 0
```

Enable compressed ram.

```
$ sudo pacman -S zram-generator
$ sudo nano /etc/systemd/zram-generator.conf
    [zram0]
    zram-size = ram
    compression-algorithm = zstd
    swap-priority = 100

$ sudo systemctl daemon-reload
$ sudo systemctl restart systemd-zram-setup@zram0.service

$ echo "vm.swappiness=80" | sudo tee /etc/sysctl.d/99-swappiness.conf
$ sudo sysctl --system
```

Enable Standard Home Directories

```
$ sudo pacman -S xdg-user-dirs
$ xdg-user-dirs-update
```

Enable Automatic `systemd-boot` Update

```
$ sudo systemctl enable systemd-boot-update.service
```

Enable Arch User Repository (AUR)

```
$ sudo pacman -S base-devel git
$ cd /tmp
$ git clone https://aur.archlinux.org/yay.git
$ cd yay
$ makepkg -si
```

Enable VMware Guest Tools 

```
$ yay -S open-vm-tools.git

--- Avoid race condition with plymouth
$ sudo systemctl edit vmtoolsd.service
    [Unit]
    After=plymouth-quit.service
```

### Reinstallation

```
# mount /dev/nvme0n1p2 /mnt
# btrfs subvolume delete /mnt/@
# btrfs subvolume create /mnt/@
# umount /mnt

# mount -o subvol=@,compress=zstd,noatime /dev/nvme0n1p2 /mnt
# mkdir -p /mnt/boot
# mount /dev/nvme0n1p1 /mnt/boot

# rm -f /mnt/boot/Image* /mnt/boot/initramfs*
```