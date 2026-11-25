#!/bin/bash
# Builds the FeatherOS ISO. Run as root inside a Debian 13 (trixie) system or container.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
WORK=/build
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  live-build debootstrap squashfs-tools xorriso mtools dosfstools \
  grub-pc-bin grub-efi-amd64-bin grub-efi-ia32-bin isolinux syslinux syslinux-common \
  ca-certificates zstd gnupg xz-utils
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
