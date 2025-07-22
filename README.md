# Ultimate Arch Linux Auto-Installer - Comprehensive Guide

![Arch Linux Logo](https://archlinux.org/static/logos/archlinux-logo-dark-1200dpi.b42bd35d5916.png)

## Table of Contents
1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Installation Process](#installation-process)
4. [Configuration Options](#configuration-options)
5. [Post-Installation](#post-installation)
6. [Troubleshooting](#troubleshooting)
7. [FAQ](#faq)
8. [Advanced Customization](#advanced-customization)

## Introduction

This script provides a streamlined installation process for Arch Linux with either KDE Plasma or GNOME desktop environments. It automates the complex installation process while maintaining flexibility through interactive configuration.

### Key Features:
- Automatic BIOS/UEFI detection
- Desktop environment selection (KDE Plasma or GNOME)
- Interactive user configuration with password validation
- Comprehensive system validation before reboot
- Logging of all installation steps
- Optimized configurations for different hardware

## Prerequisites

### Hardware Requirements
- Minimum 20GB disk space (30GB recommended)
- 2GB RAM (4GB recommended for desktop environments)
- Internet connection

### Preparation
1. Download the Arch Linux ISO from [https://archlinux.org/download/](https://archlinux.org/download/)
2. Create a bootable USB:
   ```bash
   dd bs=4M if=archlinux.iso of=/dev/sdX status=progress oflag=sync
   ```
   (Replace `/dev/sdX` with your USB device)

3. Boot from the USB and ensure you have internet connectivity

## Installation Process

### Step 1: Download the Script
From the Arch Linux live environment:
```bash
curl -O https://github.com/LinuxFurry-boop/Arch-Linux-Installer-Ultra
chmod +x arch-autoinstaller.sh
```

### Step 2: Run the Installer
```bash
sudo ./arch-autoinstaller.sh
```

### Step 3: Interactive Configuration
The script will guide you through:
1. **Desktop Environment Selection**:
   - Choose between KDE Plasma or GNOME
   - KDE recommended for most users
   - GNOME recommended for touchscreen devices

2. **User Configuration**:
   - Set your username
   - Set both user and root passwords
   - Configure hostname

### Step 4: Installation Process
The script will automatically:
1. Detect your system firmware (BIOS/UEFI)
2. Partition your disk (with swap space)
3. Install the base system
4. Configure bootloader (GRUB for BIOS, systemd-boot for UEFI)
5. Install your selected desktop environment
6. Perform system validation

### Step 5: Reboot
After successful installation:
```bash
reboot
```

## Configuration Options

### Pre-Installation Customization
You can edit the script before running it to modify default values:

```bash
nano arch-autoinstaller.sh
```

Key configuration variables:
```bash
TARGET_DISK="/dev/nvme0n1"  # Change to your target disk (e.g., /dev/sda)
HOSTNAME="archbox"          # Default hostname
USERNAME="user"             # Default username
TIMEZONE="America/New_York" # Timezone
LOCALE="en_US.UTF-8"        # System locale
KERNEL="linux"              # Kernel type (linux, linux-lts, linux-zen)
X11_DRIVERS="xf86-video-amdgpu" # Graphics drivers
```

### Desktop Environment Options
The script supports two desktop environments:

1. **KDE Plasma**:
   - Includes Dolphin file manager
   - Konsole terminal
   - Full KDE application suite

2. **GNOME**:
   - Nautilus file manager
   - GNOME Terminal
   - GNOME Tweaks tool

## Post-Installation

### First Steps After Installation
1. Update your system:
   ```bash
   sudo pacman -Syu
   ```

2. Install an AUR helper (recommended):
   ```bash
   sudo pacman -S --needed base-devel git
   git clone https://aur.archlinux.org/yay.git
   cd yay && makepkg -si
   ```

3. Install additional software:
   ```bash
   yay -S visual-studio-code-bin spotify
   ```

### Recommended Applications
- Web Browser: Firefox (pre-installed), Google Chrome
- Office Suite: LibreOffice
- Media: VLC
- Graphics: GIMP, Inkscape

## Troubleshooting

### Common Issues

1. **Network Connection Failed**:
   - Check connection with `ping archlinux.org`
   - Use `iwctl` for WiFi configuration:
     ```bash
     iwctl
     station list
     station wlan0 connect SSID
     ```

2. **Display Manager Issues**:
   - Switch to console with `Ctrl+Alt+F2`
   - Check logs:
     ```bash
     journalctl -u sddm -b
     # or
     journalctl -u gdm -b
     ```

3. **Boot Problems**:
   - For UEFI systems, check boot order in BIOS
   - For BIOS systems, reinstall GRUB:
     ```bash
     arch-chroot /mnt
     grub-install /dev/sdX
     grub-mkconfig -o /boot/grub/grub.cfg
     ```

### Log Files
- Installation log: `/var/log/arch-autoinstall.log`
- Validation log: `/var/log/install-validation.log`

## FAQ

**Q: Can I use this script on an existing Arch Linux installation?**  
A: No, this is designed for fresh installations only.

**Q: How do I change the disk partitioning scheme?**  
A: Edit the `partition_disk()` function in the script before running it.

**Q: Can I install both KDE and GNOME?**  
A: Yes, but you'll need to manually configure the display manager afterwards.

**Q: Is secure boot supported?**  
A: Not currently. You'll need to disable secure boot in your BIOS.

**Q: How do I add more packages to the installation?**  
A: Modify the `ADDITIONAL_PKGS` variable in the script.

## Advanced Customization

### Custom Partitioning
For advanced users who want to modify the partitioning scheme, edit the `partition_disk()` function:

```bash
partition_disk() {
    # Example custom partitioning for UEFI
    parted -s "$TARGET_DISK" mklabel gpt
    parted -s "$TARGET_DISK" mkpart "EFI" fat32 1MiB 1GiB
    parted -s "$TARGET_DISK" set 1 esp on
    parted -s "$TARGET_DISK" mkpart "ROOT" ext4 1GiB 30GiB
    parted -s "$TARGET_DISK" mkpart "HOME" ext4 30GiB -4GiB
    parted -s "$TARGET_DISK" mkpart "SWAP" linux-swap -4GiB 100%
    
    # Format partitions
    mkfs.fat -F32 "${TARGET_DISK}p1"
    mkfs.ext4 -F "${TARGET_DISK}p2"
    mkfs.ext4 -F "${TARGET_DISK}p3"
    mkswap "${TARGET_DISK}p4"
    swapon "${TARGET_DISK}p4"
    
    # Mount partitions
    mount "${TARGET_DISK}p2" /mnt
    mkdir -p /mnt/boot/efi
    mount "${TARGET_DISK}p1" /mnt/boot/efi
    mkdir -p /mnt/home
    mount "${TARGET_DISK}p3" /mnt/home
}
```

### Custom Kernel Parameters
To add or modify kernel parameters, edit the `KERNEL_OPTIONS` variable:

```bash
KERNEL_OPTIONS="rw quiet splash mitigations=off"
```

### LVM Support
For LVM setup, add these commands after partitioning:

```bash
pvcreate /dev/sdX2
vgcreate vg0 /dev/sdX2
lvcreate -L 20G -n root vg0
lvcreate -l 100%FREE -n home vg0
```

## Support

For issues not covered in this guide, please:
1. Check the Arch Linux Wiki: [https://wiki.archlinux.org/](https://wiki.archlinux.org/)
2. Search the Arch Linux forums: [https://bbs.archlinux.org/](https://bbs.archlinux.org/)
3. Open an issue on the script's GitHub repository

---

**Note:** This script is provided as-is without warranty. Always back up your data before installation.
