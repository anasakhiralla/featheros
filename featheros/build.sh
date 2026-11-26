#!/bin/bash
# Builds the FeatherOS ISO. Run as root inside a Debian 13 (trixie) system or container.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
WORK=/build
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  live-build debootstrap squashfs-tools xorriso mtools dosfstools \
  grub-pc-bin grub-efi-amd64-bin grub-efi-ia32-bin isolinux syslinux syslinux-common \
  ca-certificates zstd gnupg xz-utils fdisk
rm -rf "$WORK"; mkdir -p "$WORK"; cd "$WORK"
lb config \
  --distribution trixie \
  --architectures amd64 \
  --archive-areas "main contrib non-free non-free-firmware" \
  --binary-images iso-hybrid \
  --debian-installer none \
  --apt-recommends false \
  --uefi-secure-boot disable \
  --memtest none \
  --chroot-squashfs-compression-type zstd \
  --iso-application "FeatherOS" \
  --iso-volume "FEATHEROS" \
  --iso-publisher "FeatherOS" \
  --bootappend-live "boot=live components quiet username=feather hostname=featheros locales=en_US.UTF-8 keyboard-layouts=us timezone=Africa/Cairo"
cp -r "$SRC"/live/. config/
chmod -R +x config/hooks || true
lb build 2>&1 | tee build.log
mkdir -p "$SRC/out"
cp live-image-amd64.hybrid.iso "$SRC/out/featheros-amd64.iso"
ls -lh "$SRC/out"

echo "=== Checking the boot partition inside the ISO ==="
ISO="$SRC/out/featheros-amd64.iso"
sfdisk -d "$ISO" || true
LINE=$(sfdisk -d "$ISO" 2>/dev/null | grep -iE 'type=(ef|C12A7328)' | head -1 || true)
if [ -z "$LINE" ]; then
  echo "BOOT CHECK FAILED: the ISO has no EFI boot partition, so a USB stick made from it will not show up on UEFI firmware."
  exit 1
fi
START=$(echo "$LINE" | sed -n 's/.*start= *\([0-9]*\).*/\1/p')
SIZE=$(echo "$LINE" | sed -n 's/.*size= *\([0-9]*\).*/\1/p')
dd if="$ISO" of=/tmp/esp.img bs=512 skip="$START" count="$SIZE" status=none
mdir -/ -b -i /tmp/esp.img ::/ | tee /tmp/esp-files.txt
grep -qi 'bootx64.efi' /tmp/esp-files.txt || { echo "BOOT CHECK FAILED: bootx64.efi missing"; exit 1; }
grep -qi 'bootia32.efi' /tmp/esp-files.txt || { echo "BOOT CHECK FAILED: bootia32.efi (32-bit boot file) missing"; exit 1; }
echo "BOOT CHECK PASSED: both 64-bit and 32-bit boot files are in the ISO."
