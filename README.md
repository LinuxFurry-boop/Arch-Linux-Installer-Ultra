# Ultimate Arch Linux Auto-Installer - Comprehensive Guide

![Arch Linux Logo](https://archlinux.org/static/logos/archlinux-logo-dark-1200dpi.b42bd35d5916.png)

## Table of Contents
1. [Introduction](#introduction)
2. [Quick Start](#quick-start)
3. [Prerequisites](#prerequisites)
4. [Installation Process](#installation-process)
5. [Configuration Options](#configuration-options)
6. [Post-Installation](#post-installation)
7. [Troubleshooting](#troubleshooting)
8. [FAQ](#faq)
9. [Advanced Customization](#advanced-customization)
10. [Contributing](#contributing)

## Introduction

**ArchInstall.sh** is an advanced, user-friendly installer for Arch Linux that automates the installation process while maintaining the flexibility and minimalism that Arch Linux is known for. The script is maintained at [GitHub](https://github.com/LinuxFurry-boop/Arch-Linux-Installer-Ultra).

### Key Features:
- Automatic BIOS/UEFI detection and configuration
- Interactive desktop environment selection (KDE Plasma or GNOME)
- Graphical user configuration interface
- Comprehensive pre-reboot system validation
- Detailed logging of all installation steps
- Optimized configurations for different hardware
- Built-in troubleshooting and repair tools

## Quick Start

### For Experienced Users:
1. Boot Arch Linux ISO
2. Download and run the installer:
   ```bash
   curl -L -o ArchInstall.sh https://raw.githubusercontent.com/LinuxFurry-boop/Arch-Linux-Installer-Ultra/main/ArchInstall.sh
   chmod +x ArchInstall.sh
   sudo ./ArchInstall.sh
   ```

## Prerequisites

### Hardware Requirements
- Minimum 20GB disk space (30GB recommended for desktop environments)
- 2GB RAM (4GB recommended)
- Internet connection (wired recommended during installation)

### Preparation Steps
1. **Download Arch Linux ISO**:
   ```bash
   wget https://archlinux.org/iso/latest/archlinux-x86_64.iso
   ```

2. **Create Bootable USB**:
   ```bash
   dd bs=4M if=archlinux-x86_64.iso of=/dev/sdX status=progress oflag=sync
   ```
   Replace `/dev/sdX` with your USB device (e.g., `/dev/sdb`)

3. **Boot from USB** and connect to internet:
   - For wired: Should work automatically
   - For WiFi: Use `iwctl`
     ```bash
     iwctl
     station wlan0 connect SSID
     ```

## Installation Process

### Step-by-Step Walkthrough

1. **Launch the Installer**:
   ```bash
   sudo ./ArchInstall.sh
   ```

2. **Desktop Environment Selection**:
   ```
   ■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■
   │ SELECT DESKTOP ENVIRONMENT                     │
   ■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■

   Choose your preferred desktop environment:

   1. KDE Plasma (Modern, feature-rich)
      - Includes Dolphin, Konsole, and KDE apps
      - Recommended for most users

   2. GNOME (Clean, minimalist)
      - Includes Nautilus, GNOME Terminal
      - Great for touchscreen devices

   Enter your choice [1-2]: 
   ```

3. **User Configuration**:
   ```
   ■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■
   │ USER ACCOUNT CONFIGURATION                     │
   ■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■

   MAIN USER ACCOUNT
     Username [user]: yourname
     Password: ********
     Repeat Password: ********

   ROOT ACCOUNT
     Hostname [archbox]: myarchpc
     Root Password: ********
     Repeat Root Password: ********

   ■ Configuration Summary ■
     User: yourname
     Hostname: myarchpc
   ```

4. **Installation Progress**:
   - The script will show real-time progress of:
     - Disk partitioning
     - Base system installation
     - Bootloader configuration
     - Desktop environment setup
   - All actions are logged to `/var/log/arch-autoinstall.log`

5. **System Validation**:
   - Automatic checks for:
     - Bootloader configuration
     - Display manager functionality
     - Network connectivity
     - Graphics support
   - Results saved to `/mnt/var/log/install-validation.log`

6. **Completion**:
   ```
   ■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■
   │ ARCH LINUX INSTALLATION COMPLETE!               │
   ■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■

   System Configuration:
     Username: yourname
     Hostname: myarchpc
     Desktop: KDE Plasma

   Next steps after reboot:
   1. Login as yourname
   2. Run updates: sudo pacman -Syu
   3. Install AUR helper: yay (instructions in README)

   Ready to reboot! Type: reboot
   ```

## Configuration Options

### Pre-Installation Customization
Edit the script before running to modify defaults:

```bash
nano ArchInstall.sh
```

Key variables to customize:
```bash
# Disk and partitioning
TARGET_DISK="/dev/nvme0n1"  # Change to your target disk

# System configuration
HOSTNAME="archbox"
USERNAME="user"
TIMEZONE="America/New_York"
LOCALE="en_US.UTF-8"

# Hardware specific
KERNEL="linux"              # Options: linux, linux-lts, linux-zen
X11_DRIVERS="xf86-video-amdgpu" # Change for Intel/NVIDIA

# Additional packages
ADDITIONAL_PKGS="firefox git base-devel"
```

### Desktop Environment Options

| Feature               | KDE Plasma                          | GNOME                              |
|-----------------------|-------------------------------------|------------------------------------|
| Display Manager       | SDDM                                | GDM                                |
| File Manager         | Dolphin                             | Nautilus                           |
| Terminal             | Konsole                             | GNOME Terminal                     |
| Recommended For      | Power users, customization         | Touch devices, simplicity         |
| Default Applications | Kate, KCalc, Gwenview              | gedit, Calculator, Eye of GNOME   |

## Post-Installation

### Essential First Steps
1. **Update System**:
   ```bash
   sudo pacman -Syu
   ```

2. **Install AUR Helper (yay)**:
   ```bash
   sudo pacman -S --needed base-devel git
   git clone https://aur.archlinux.org/yay.git
   cd yay && makepkg -si
   ```

3. **Install Additional Software**:
   ```bash
   yay -S visual-studio-code-bin spotify
   ```

### Recommended Packages

| Category       | KDE Plasma Packages              | GNOME Packages                    |
|---------------|----------------------------------|-----------------------------------|
| Office        | libreoffice-fresh calligra       | libreoffice-fresh gnome-office    |
| Media         | vlc kdenlive elisa               | vlc pitivi gnome-music           |
| Graphics      | gimp krita okular                | gimp inkscape evince             |
| Utilities     | krusader yakuake                 | gnome-tweaks gnome-boxes         |

## Troubleshooting

### Common Issues and Solutions

1. **Boot Issues**:
   - *UEFI Systems*: Check boot order in BIOS
   - *BIOS Systems*: Reinstall GRUB:
     ```bash
     sudo grub-install /dev/sdX
     sudo grub-mkconfig -o /boot/grub/grub.cfg
     ```

2. **Display Problems**:
   - Check active display manager:
     ```bash
     sudo systemctl status sddm  # or gdm
     ```
   - Switch to console: `Ctrl+Alt+F2`

3. **Network Issues**:
   - Enable NetworkManager:
     ```bash
     sudo systemctl enable --now NetworkManager
     ```

### Log Files Location
- Installation log: `/var/log/arch-autoinstall.log`
- Validation log: `/var/log/install-validation.log`

## FAQ

**Q: Can I install without a desktop environment?**
A: Yes, modify the script to skip desktop environment installation or choose minimal base.

**Q: How do I add LUKS encryption?**
A: Currently not supported in this version. Check GitHub for future updates.

**Q: Can I run this on existing Arch install?**
A: No, this is for fresh installations only.

**Q: Secure Boot support?**
A: Not currently supported. Disable Secure Boot in BIOS.

## Advanced Customization

### Custom Partitioning Example
Edit the `partition_disk()` function:

```bash
partition_disk() {
    parted -s "$TARGET_DISK" mklabel gpt
    parted -s "$TARGET_DISK" mkpart "EFI" fat32 1MiB 1GiB
    parted -s "$TARGET_DISK" set 1 esp on
    parted -s "$TARGET_DISK" mkpart "ROOT" ext4 1GiB 30GiB
    parted -s "$TARGET_DISK" mkpart "HOME" ext4 30GiB 100%
    
    mkfs.fat -F32 "${TARGET_DISK}p1"
    mkfs.ext4 -F "${TARGET_DISK}p2"
    mkfs.ext4 -F "${TARGET_DISK}p3"
    
    mount "${TARGET_DISK}p2" /mnt
    mkdir -p /mnt/{boot/efi,home}
    mount "${TARGET_DISK}p1" /mnt/boot/efi
    mount "${TARGET_DISK}p3" /mnt/home
}
```

### LVM Setup
Add after partitioning:

```bash
pvcreate /dev/sdX2
vgcreate vg0 /dev/sdX2
lvcreate -L 20G -n root vg0
lvcreate -l 100%FREE -n home vg0
```

## Contributing

We welcome contributions! Please:

1. Fork the repository: [GitHub](https://github.com/LinuxFurry-boop/Arch-Linux-Installer-Ultra)
2. Create a feature branch
3. Submit a pull request

### Reporting Issues
Please include:
- Exact error messages
- Contents of relevant log files
- Steps to reproduce the issue

---

**Note:** Always back up important data before installation. This script is provided as-is without warranty. For official Arch Linux documentation, visit [https://wiki.archlinux.org/](https://wiki.archlinux.org/).
