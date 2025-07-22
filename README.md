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

The **Ultimate Arch Linux Auto-Installer** is a comprehensive installation script that simplifies the Arch Linux installation process while maintaining the flexibility and power of a manual installation. The project is hosted on GitHub at:

🔗 [https://github.com/LinuxFurry-boop/Arch-Linux-Installer-Ultra](https://github.com/LinuxFurry-boop/Arch-Linux-Installer-Ultra)

The main installation script is named `ArchInstall.sh`.

### Key Features:
- **Automatic hardware detection** (BIOS/UEFI, CPU microcode)
- **Interactive desktop environment selection** (KDE Plasma or GNOME)
- **Graphical user configuration** with password validation
- **Comprehensive system validation** before reboot
- **Detailed logging** of all installation steps
- **Optimized configurations** for different hardware
- **Built-in troubleshooting** and repair tools

## Quick Start

### Direct Download and Execution:
```bash
curl -L -O https://raw.githubusercontent.com/LinuxFurry-boop/Arch-Linux-Installer-Ultra/main/ArchInstall.sh
chmod +x ArchInstall.sh
sudo ./ArchInstall.sh
```

### Alternative Download Methods:
1. **Via GitHub Clone**:
   ```bash
   git clone https://github.com/LinuxFurry-boop/Arch-Linux-Installer-Ultra.git
   cd Arch-Linux-Installer-Ultra
   chmod +x ArchInstall.sh
   sudo ./ArchInstall.sh
   ```

2. **Using wget**:
   ```bash
   wget https://raw.githubusercontent.com/LinuxFurry-boop/Arch-Linux-Installer-Ultra/main/ArchInstall.sh
   chmod +x ArchInstall.sh
   sudo ./ArchInstall.sh
   ```

## Prerequisites

### Hardware Requirements
| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Storage   | 20GB    | 30GB+       |
| RAM       | 2GB     | 4GB+        |
| CPU       | x86_64  | Modern CPU  |

### Preparation Checklist
1. [Download Arch ISO](https://archlinux.org/download/)
2. Create bootable USB:
   ```bash
   dd if=archlinux-x86_64.iso of=/dev/sdX bs=4M status=progress oflag=sync
   ```
3. Boot from USB and connect to internet
4. Verify internet connection:
   ```bash
   ping archlinux.org
   ```

## Installation Process

### Step-by-Step Guide

1. **Launch the Installer**:
   ```bash
   sudo ./ArchInstall.sh
   ```

2. **Desktop Selection**:
   ```
   ■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■
   │ SELECT DESKTOP ENVIRONMENT                     │
   ■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■
   [1] KDE Plasma (Recommended for most users)
   [2] GNOME (Clean, minimalist interface)
   ```

3. **User Configuration**:
   ```
   ■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■
   │ USER ACCOUNT CONFIGURATION                     │
   ■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■
   Username: myuser
   Password: ********
   Hostname: myarch
   Root Password: ********
   ```

4. **Installation Progress**:
   - Automatic partitioning (with swap calculation)
   - Base system installation
   - Desktop environment setup
   - Bootloader configuration
   - System validation

5. **Completion**:
   ```
   ■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■
   │ ARCH LINUX INSTALLATION COMPLETE!              │
   ■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■
   System ready for use. Type 'reboot' to restart.
   ```

## Configuration Options

### Script Customization
Edit these variables in `ArchInstall.sh`:

```bash
# Disk configuration
TARGET_DISK="/dev/nvme0n1"  # Change to your disk

# System configuration
HOSTNAME="archbox"
USERNAME="user"
TIMEZONE="America/New_York"
LOCALE="en_US.UTF-8"

# Package selection
KERNEL="linux"              # linux, linux-lts, linux-zen
X11_DRIVERS="xf86-video-amdgpu" # Change for your GPU
ADDITIONAL_PKGS="firefox git base-devel"
```

### Desktop Environment Comparison

| Feature        | KDE Plasma                     | GNOME                         |
|---------------|--------------------------------|-------------------------------|
| Resource Use  | Moderate                       | Moderate-Heavy               |
| Customization | Extensive                      | Limited                      |
| Default Apps  | Dolphin, Konsole, Kate        | Nautilus, GNOME Terminal     |
| Best For      | Power users, customization    | Simplicity, touch devices    |

## Post-Installation

### Essential Commands
1. **Update System**:
   ```bash
   sudo pacman -Syu
   ```

2. **Install yay (AUR Helper)**:
   ```bash
   git clone https://aur.archlinux.org/yay.git
   cd yay && makepkg -si
   ```

3. **Recommended Packages**:
   ```bash
   yay -S visual-studio-code-bin spotify
   ```

### Maintenance Tips
- Regular updates:
  ```bash
  yay -Syu
  ```
- Clean package cache:
  ```bash
  yay -Sc
  ```

## Troubleshooting

### Common Issues

| Problem                  | Solution                                  |
|--------------------------|------------------------------------------|
| No internet              | `dhcpcd` or `iwctl` for WiFi            |
| Display manager fails    | Check logs with `journalctl -u sddm`     |
| Boot issues              | Reinstall bootloader (see GitHub FAQ)    |
| Sound not working        | Install `pulseaudio-alsa` (for ALSA)    |

### Log Files
- Installation log: `/var/log/arch-autoinstall.log`
- Validation log: `/var/log/install-validation.log`

## FAQ

**Q: Can I install both KDE and GNOME?**  
A: Yes, but manual configuration of display manager will be needed.

**Q: How to add LUKS encryption?**  
A: Currently not supported in this version.

**Q: Secure Boot support?**  
A: Not currently - disable Secure Boot in BIOS.

**Q: Can I use this on existing Arch install?**  
A: No, fresh installations only.

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
    ...
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

1. Fork the repository:  
   [https://github.com/LinuxFurry-boop/Arch-Linux-Installer-Ultra](https://github.com/LinuxFurry-boop/Arch-Linux-Installer-Ultra)

2. Create a feature branch

3. Submit a pull request

### Reporting Issues
Include:
- Exact error messages
- Relevant log files
- Steps to reproduce

---

**Note:** Always back up important data before installation. For official Arch Linux documentation, visit [https://wiki.archlinux.org/](https://wiki.archlinux.org/).
