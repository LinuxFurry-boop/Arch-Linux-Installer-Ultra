#!/bin/bash
# Ultimate Arch Linux Auto-Installer
# Features: BIOS/UEFI detection, desktop selection, user configuration GUI, pre-reboot validation

# ==============================================
# SELF-IDENTIFICATION HEADER
# ==============================================
if [[ "$0" =~ "curl" ]] || [[ ! -f "$0" ]]; then
    clear
    echo -e "\n\033[1;36m■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■"
    echo -e "│ \033[1;32mARCH LINUX AUTO-INSTALLER\033[0m \033[1;33m(GNOME/KDE PLASMA)\033[0m       │"
    echo -e "■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■\033[0m"
    echo -e "\nTo begin installation:\n"
    echo -e "  \033[1;37m1. Make executable:\033[0m \033[1;33mchmod +x ${0##*/}\033[0m"
    echo -e "  \033[1;37m2. Run as root:\033[0m \033[1;33msudo ./${0##*/}\033[0m\n"
    echo -e "\033[1;31m■ WARNING: This will modify your disk partitions!\033[0m"
    echo -e "\033[1;34m■ Tip: Run 'nano ${0##*/}' to review config first\033[0m"
    exit 0
fi

# ==============================================
# CONFIGURATION SECTION
# ==============================================
TARGET_DISK="/dev/nvme0n1"  # Adjust to your disk
HOSTNAME="archbox"
USERNAME="user"
PASSWORD="arch123"  # Will be changed in GUI
TIMEZONE="America/New_York"
LOCALE="en_US.UTF-8"
KERNEL="linux"               # linux, linux-lts, linux-zen
X11_DRIVERS="xf86-video-amdgpu" # xf86-video-intel, nvidia, etc.
ADDITIONAL_PKGS="firefox git base-devel" # Space-separated

# Desktop Environment (Will be selected interactively)
DESKTOP_ENV=""
DISPLAY_MANAGER=""

# ==============================================
# GLOBAL VARIABLES
# ==============================================
EFI_MODE="false"
LOG_FILE="/var/log/arch-autoinstall.log"
VALIDATION_LOG="/mnt/var/log/install-validation.log"
BOOTLOADER_PKGS=""
MICROCODE=""
KERNEL_OPTIONS=""
ROOT_PASSWORD=""

# ==============================================
# FUNCTION DEFINITIONS
# ==============================================

# --- Logging and Error Handling ---
init_logging() {
    echo "=== Arch Auto-Install Started $(date) ===" > "$LOG_FILE"
    exec 3>&1 4>&2
    exec 1>>"$LOG_FILE" 2>&1
    trap 'exec 1>&3 2>&4' EXIT
}

log() {
    echo -e "[$(date '+%H:%M:%S')] $1" | tee /dev/fd/3
}

die() {
    log "[ERROR] $1"
    echo "Check $LOG_FILE for details"
    exit 1
}

# --- Desktop Selection ---
select_desktop() {
    clear
    echo -e "\n\033[1;36m■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■"
    echo -e "│ \033[1;32mSELECT DESKTOP ENVIRONMENT\033[0m                     │"
    echo -e "■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■\033[0m"
    echo -e "\n\033[1;37mChoose your preferred desktop environment:\033[0m\n"
    echo -e "  \033[1;33m1. KDE Plasma\033[0m (Modern, feature-rich)"
    echo -e "     - Includes Dolphin, Konsole, and KDE apps"
    echo -e "     - Recommended for most users\n"
    echo -e "  \033[1;35m2. GNOME\033[0m (Clean, minimalist)"
    echo -e "     - Includes Nautilus, GNOME Terminal"
    echo -e "     - Great for touchscreen devices\n"
    echo -ne "\n\033[1;37mEnter your choice [1-2]: \033[0m"

    read -r choice
    case $choice in
        1)
            DESKTOP_ENV="plasma-desktop plasma-nm plasma-pa dolphin konsole"
            DISPLAY_MANAGER="sddm"
            echo -e "\n\033[1;32mSelected: KDE Plasma\033[0m"
            ;;
        2)
            DESKTOP_ENV="gnome gnome-extra gnome-tweaks"
            DISPLAY_MANAGER="gdm"
            echo -e "\n\033[1;32mSelected: GNOME\033[0m"
            ;;
        *)
            echo -e "\n\033[1;31mInvalid choice! Defaulting to KDE Plasma\033[0m"
            DESKTOP_ENV="plasma-desktop plasma-nm plasma-pa dolphin konsole"
            DISPLAY_MANAGER="sddm"
            ;;
    esac
    
    # Add common desktop packages
    DESKTOP_ENV+=" ark gparted spectacle gnome-boxes" # Useful for both environments
    sleep 2
}

# --- User Configuration GUI ---
user_config_gui() {
    clear
    echo -e "\n\033[1;36m■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■"
    echo -e "│ \033[1;32mUSER ACCOUNT CONFIGURATION\033[0m                     │"
    echo -e "■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■\033[0m"
    
    # Main user configuration
    echo -e "\n\033[1;37mMAIN USER ACCOUNT\033[0m"
    read -p "  Username [$USERNAME]: " input_user
    USERNAME=${input_user:-$USERNAME}
    
    while true; do
        read -s -p "  Password: " user_pass
        echo
        read -s -p "  Repeat Password: " user_pass2
        echo
        if [ "$user_pass" = "$user_pass2" ]; then
            PASSWORD="$user_pass"
            break
        else
            echo -e "\033[1;31mPasswords don't match! Try again.\033[0m"
        fi
    done
    
    # Root password configuration
    echo -e "\n\033[1;37mROOT ACCOUNT\033[0m"
    read -p "  Hostname [$HOSTNAME]: " input_host
    HOSTNAME=${input_host:-$HOSTNAME}
    
    while true; do
        read -s -p "  Root Password: " root_pass
        echo
        read -s -p "  Repeat Root Password: " root_pass2
        echo
        if [ "$root_pass" = "$root_pass2" ]; then
            ROOT_PASSWORD="$root_pass"
            break
        else
            echo -e "\033[1;31mPasswords don't match! Try again.\033[0m"
        fi
    done
    
    # Summary
    echo -e "\n\033[1;34m■ Configuration Summary ■\033[0m"
    echo -e "  User: \033[1;33m$USERNAME\033[0m"
    echo -e "  Hostname: \033[1;33m$HOSTNAME\033[0m"
    echo -ne "\n\033[1;37mProceed with installation? [y/N]: \033[0m"
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "\n\033[1;31mInstallation cancelled by user.\033[0m"
        exit 1
    fi
}

# --- System Detection ---
detect_system() {
    if [[ -d /sys/firmware/efi/efivars ]]; then
        EFI_MODE="true"
        log "System detected: UEFI Mode"
    else
        log "System detected: BIOS (Legacy) Mode"
    fi
}

configure_firmware_specifics() {
    if [[ "$EFI_MODE" == "true" ]]; then
        log "Applying UEFI-specific optimizations..."
        BOOTLOADER_PKGS="efibootmgr edk2-shell"
        KERNEL_OPTIONS="rw quiet"
        
        CPU_VENDOR=$(grep -m 1 -oP 'vendor_id\s*:\s*\K\w+' /proc/cpuinfo)
        if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
            MICROCODE="intel-ucode"
        elif [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
            MICROCODE="amd-ucode"
        fi
    else
        log "Applying BIOS-specific optimizations..."
        BOOTLOADER_PKGS="grub"
        KERNEL_OPTIONS="rw quiet"
    fi
}

# --- Installation Functions ---
configure_network() {
    if ! ping -c 1 archlinux.org &> /dev/null; then
        log "Setting up network..."
        if ! dhcpcd &> /dev/null; then
            log "Network setup failed. Starting interactive iwd..."
            iwctl
            die "Please configure network manually and restart script"
        fi
    fi
}

partition_disk() {
    log "Partitioning $TARGET_DISK..."
    
    if [[ "$EFI_MODE" == "true" ]]; then
        parted -s "$TARGET_DISK" mklabel gpt
        parted -s "$TARGET_DISK" mkpart "EFI" fat32 1MiB 513MiB
        parted -s "$TARGET_DISK" set 1 esp on
        parted -s "$TARGET_DISK" mkpart "ROOT" ext4 513MiB -4GiB
        parted -s "$TARGET_DISK" mkpart "SWAP" linux-swap -4GiB 100%
        
        mkfs.fat -F32 "${TARGET_DISK}p1" || die "Failed to format EFI partition"
        mkfs.ext4 -F "${TARGET_DISK}p2" || die "Failed to format root partition"
        mkswap "${TARGET_DISK}p3" || die "Failed to create swap"
        swapon "${TARGET_DISK}p3"
        
        mount "${TARGET_DISK}p2" /mnt || die "Failed to mount root"
        mkdir -p /mnt/boot/efi
        mount "${TARGET_DISK}p1" /mnt/boot/efi || die "Failed to mount EFI"
    else
        parted -s "$TARGET_DISK" mklabel msdos
        parted -s "$TARGET_DISK" mkpart primary ext4 1MiB -4GiB
        parted -s "$TARGET_DISK" set 1 boot on
        parted -s "$TARGET_DISK" mkpart primary linux-swap -4GiB 100%
        
        mkfs.ext4 -F "${TARGET_DISK}1" || die "Failed to format root partition"
        mkswap "${TARGET_DISK}2" || die "Failed to create swap"
        swapon "${TARGET_DISK}2"
        
        mount "${TARGET_DISK}1" /mnt || die "Failed to mount root"
    fi
}

install_base() {
    log "Installing system with firmware-specific packages..."
    BASE_PKGS="base $KERNEL linux-firmware nano sudo networkmanager $X11_DRIVERS"
    ALL_PKGS="$BASE_PKGS $BOOTLOADER_PKGS $MICROCODE"
    
    pacstrap /mnt $ALL_PKGS || die "Base system installation failed"
    genfstab -U /mnt >> /mnt/etc/fstab || die "Failed to generate fstab"
}

configure_system() {
    log "Configuring base system..."
    
    arch-chroot /mnt /bin/bash <<EOF || die "Chroot configuration failed"
        # Set root password
        echo "root:$ROOT_PASSWORD" | chpasswd
        
        # User creation
        useradd -m -G wheel -s /bin/bash "$USERNAME"
        echo "$USERNAME:$PASSWORD" | chpasswd
        
        # System configuration
        ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
        hwclock --systohc
        sed -i "s/#$LOCALE/$LOCALE/" /etc/locale.gen
        locale-gen
        echo "LANG=$LOCALE" > /etc/locale.conf
        echo "$HOSTNAME" > /etc/hostname
        echo "127.0.0.1 localhost" >> /etc/hosts
        echo "::1 localhost" >> /etc/hosts
        echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts
        sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
EOF
}

configure_bootloader() {
    arch-chroot /mnt /bin/bash <<EOF || die "Bootloader configuration failed"
        if [[ "$EFI_MODE" == "true" ]]; then
            bootctl install || exit 1
            
            cat > /etc/mkinitcpio.d/$KERNEL.preset <<PRESET_EOF
ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-$KERNEL"

PRESETS=('default' 'fallback')

default_image="/boot/initramfs-$KERNEL.img"
default_uki="/efi/EFI/arch/arch-linux.efi"
default_options="--splash /usr/share/systemd/bootctl/splash-arch.bmp"

fallback_image="/boot/initramfs-$KERNEL-fallback.img"
fallback_uki="/efi/EFI/arch/arch-linux-fallback.efi"
fallback_options="-S autodetect"
PRESET_EOF

            mkinitcpio -P || exit 1
            
            mkdir -p /boot/loader/entries
            cat > /boot/loader/loader.conf <<LOADER_EOF
default arch
timeout 3
editor no
console-mode keep
LOADER_EOF

            cat > /boot/loader/entries/arch.conf <<ENTRY_EOF
title Arch Linux
linux /vmlinuz-$KERNEL
initrd /$MICROCODE.img
initrd /initramfs-$KERNEL.img
options root="UUID=$(blkid -s UUID -o value ${TARGET_DISK}p2)" $KERNEL_OPTIONS
ENTRY_EOF
            
        else
            pacman -S --noconfirm grub || exit 1
            grub-install --target=i386-pc "$TARGET_DISK" || exit 1
            grub-mkconfig -o /boot/grub/grub.cfg || exit 1
        fi
EOF
}

install_desktop() {
    log "Installing desktop environment..."
    
    arch-chroot /mnt /bin/bash <<EOF
        # Install selected desktop
        pacman -S --noconfirm $DESKTOP_ENV $DISPLAY_MANAGER $ADDITIONAL_PKGS || exit 1
        
        # Enable services
        systemctl enable NetworkManager || exit 1
        systemctl enable $DISPLAY_MANAGER || {
            echo "[WARNING] Primary display manager failed, trying fallback..."
            if [[ "$DISPLAY_MANAGER" == "sddm" ]]; then
                pacman -S --noconfirm lightdm lightdm-gtk-greeter || exit 1
                systemctl enable lightdm || exit 1
            else
                exit 1
            fi
        }
        
        # Desktop-specific optimizations
        if [[ "$DESKTOP_ENV" == *"plasma"* ]]; then
            # KDE Plasma tweaks
            echo "[General]" > /etc/sddm.conf
            echo "Numlock=on" >> /etc/sddm.conf
        else
            # GNOME tweaks
            sudo -u $USERNAME dbus-launch gsettings set org.gnome.desktop.interface enable-animations true
        fi
EOF
}

validate_system() {
    log "Starting system validation..."
    
    arch-chroot /mnt /bin/bash <<VALIDATION_EOF
        echo "=== System Validation Started $(date) ===" > "$VALIDATION_LOG"
        
        echo -e "\n=== Systemd Unit Check ===" >> "$VALIDATION_LOG"
        if ! systemd-analyze verify >> "$VALIDATION_LOG" 2>&1; then
            echo "[FAIL] Systemd unit verification failed" | tee -a "$VALIDATION_LOG"
            systemctl list-units --failed --no-legend >> "$VALIDATION_LOG"
        fi
        
        echo -e "\n=== Display Manager Test ===" >> "$VALIDATION_LOG"
        if [[ "$DISPLAY_MANAGER" == "sddm" ]]; then
            if ! sddm --test-mode --example-config >> "$VALIDATION_LOG" 2>&1; then
                echo "[FAIL] SDDM test failed" | tee -a "$VALIDATION_LOG"
                pacman -S --noconfirm lightdm lightdm-gtk-greeter >> "$VALIDATION_LOG" 2>&1
                systemctl enable lightdm >> "$VALIDATION_LOG" 2>&1
            fi
        else
            if ! lightdm --test-mode >> "$VALIDATION_LOG" 2>&1; then
                echo "[FAIL] LightDM test failed" | tee -a "$VALIDATION_LOG"
            fi
        fi
        
        echo -e "\n=== Network Test ===" >> "$VALIDATION_LOG"
        if ! ping -c 3 archlinux.org >> "$VALIDATION_LOG" 2>&1; then
            echo "[FAIL] Network connectivity test failed" | tee -a "$VALIDATION_LOG"
            journalctl -u NetworkManager --no-pager -n 20 >> "$VALIDATION_LOG"
        fi
        
        echo -e "\n=== Graphics Test ===" >> "$VALIDATION_LOG"
        Xorg -noreset -logfile /var/log/Xorg-test.log :99 & X_PID=\$!
        sleep 3
        if ! ps -p \$X_PID > /dev/null; then
            echo "[FAIL] Xorg test failed" | tee -a "$VALIDATION_LOG"
            cat /var/log/Xorg-test.log >> "$VALIDATION_LOG"
        else
            kill \$X_PID
            echo "[SUCCESS] Graphics test passed" >> "$VALIDATION_LOG"
        fi
        
        if grep -q "FAIL" "$VALIDATION_LOG"; then
            echo -e "\n!!! SYSTEM VALIDATION FAILED !!!" | tee -a "$VALIDATION_LOG"
            exit 1
        else
            echo -e "\nSYSTEM VALIDATION PASSED" | tee -a "$VALIDATION_LOG"
            exit 0
        fi
VALIDATION_EOF

    local validation_result=$?
    
    if [[ $validation_result -ne 0 ]]; then
        log "Validation failed - starting repair shell"
        log "Check $VALIDATION_LOG for details"
        arch-chroot /mnt /bin/bash
        read -p "Press enter to continue after repairs..."
    else
        log "System validation passed successfully"
    fi
}

# ==============================================
# MAIN EXECUTION FLOW
# ==============================================
main() {
    init_logging
    
    # Initial setup
    detect_system
    configure_firmware_specifics
    configure_network
    
    # User selections
    select_desktop
    user_config_gui
    
    # Installation process
    partition_disk
    install_base
    configure_system
    configure_bootloader
    install_desktop
    validate_system
    
    # Completion message
    clear
    echo -e "\n\033[1;36m■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■"
    echo -e "│ \033[1;32mARCH LINUX INSTALLATION COMPLETE!\033[0m               │"
    echo -e "■━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━■\033[0m"
    
    echo -e "\n\033[1;33mSystem Configuration:\033[0m"
    echo -e "  Username: \033[1;33m$USERNAME\033[0m"
    echo -e "  Hostname: \033[1;33m$HOSTNAME\033[0m"
    
    if [[ "$DESKTOP_ENV" == *"plasma"* ]]; then
        echo -e "  Desktop: \033[1;33mKDE Plasma\033[0m"
    else
        echo -e "  Desktop: \033[1;35mGNOME\033[0m"
    fi
    
    echo -e "\n\033[1;37mNext steps after reboot:\033[0m"
    echo -e "1. Login as \033[1;33m$USERNAME\033[0m"
    echo -e "2. Open terminal and run updates:"
    echo -e "   \033[1;33msudo pacman -Syu\033[0m"
    echo -e "3. Install AUR helper (optional):"
    echo -e "   \033[1;33msudo pacman -S --needed base-devel git\033[0m"
    echo -e "   \033[1;33mgit clone https://aur.archlinux.org/yay.git\033[0m"
    echo -e "   \033[1;33mcd yay && makepkg -si\033[0m"
    
    umount -R /mnt
    echo -e "\n\033[1;32mReady to reboot! Type: \033[1;33mreboot\033[0m"
}

main