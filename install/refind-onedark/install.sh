#!/usr/bin/env bash
# Installs rEFInd with the One Dark theme. Run with sudo.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
ESP="$(bootctl --print-esp-path)"
DEST="$ESP/EFI/refind"

pacman -S --needed --noconfirm refind efibootmgr

install -d "$DEST/themes/onedark/icons"
install -m644 /usr/share/refind/refind_x64.efi "$DEST/refind_x64.efi"
install -m644 "$SRC/refind.conf" "$DEST/refind.conf"
install -m644 "$SRC"/theme/*.{png,conf} "$DEST/themes/onedark/"
install -m644 "$SRC"/theme/icons/*.png "$DEST/themes/onedark/icons/"

install -m755 "$SRC/95-refind.install" /etc/kernel/install.d/95-refind.install
KERNEL_INSTALL_BOOT_ROOT="$ESP" /etc/kernel/install.d/95-refind.install
echo "--- generated entry:"; cat "$DEST/entries.conf"

# add rEFInd to firmware boot menu (first in order); systemd-boot stays as fallback
if ! efibootmgr | grep -q 'rEFInd'; then
    dev="$(findmnt -no SOURCE "$ESP")"
    disk="/dev/$(lsblk -no PKNAME "$dev")"
    part="$(cat /sys/class/block/${dev##*/}/partition)"
    efibootmgr --create --disk "$disk" --part "$part" --loader '\EFI\refind\refind_x64.efi' --label 'rEFInd' >/dev/null
fi
efibootmgr | grep -E 'BootOrder|rEFInd|Linux Boot Manager'
echo "Done. Reboot to see it."
