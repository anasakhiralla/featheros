# FeatherOS

A light Debian 13 (64-bit) system with XFCE for the RCA Cambio 2-in-1 (2 GB RAM, 32 GB storage).
It boots on 32-bit UEFI firmware.

## Build the ISO with GitHub (free, no powerful PC needed)

1. Make a free account at github.com and create a new PUBLIC repository named `featheros`.
2. Upload everything in this folder to it, including the hidden `.github` folder
   (in MX Linux file manager press Ctrl+H to show hidden folders, then drag all items into the page).
   If `.github/workflows/build.yml` did not upload, click Add file > Create new file, type
   `.github/workflows/build.yml` as the name and paste the contents of that file.
3. Open the Actions tab, pick "Build FeatherOS ISO", press Run workflow.
4. Wait 40 to 90 minutes. When it turns green, open the run and download `featheros-iso` at the bottom.
5. Unzip it. You get `featheros-amd64.iso`.

## Make the USB stick (4 GB or bigger, it will be erased)

On MX Linux: open "MX Live USB Maker" or Menu > Accessories > "Disk" tools, or run:

    sudo dd if=featheros-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync

Replace `sdX` with your USB stick (check with `lsblk`). Be careful: the wrong letter erases the wrong disk.

## Boot the tablet

1. Back up your files first.
2. Switch the tablet off, plug in the USB stick (use a small hub if you need a keyboard too).
3. Turn it on and tap Esc or Del or F2 or F7 repeatedly to open the boot menu or BIOS.
4. Turn Secure Boot off if the option exists, then pick the USB stick.
5. At the menu choose the first entry (Live system).

Live login: user `feather`, password `live`.

## Test before installing

Check wifi, Bluetooth, sound, touch, rotation, the on-screen keyboard and long press.
Write down what fails. Useful commands to send back:

    lspci ; lsusb ; dmesg | grep -iE 'silead|gsl|goodix|rtl|bluetooth|firmware' ; aplay -l

## Install

Double-click "Install FeatherOS" on the desktop. Choose language, keyboard, "Erase disk", name and password.

## Helpers

- `featheros-dock bottom|top|left|right start|center|end [size] [length%]`
- `featheros-rotate auto|normal|left|right|inverted`
- `featheros-wallpaper picture.jpg`
- `featheros-accent "#2E6F95" light|dark`
- Touch settings: ~/.config/featheros/touch.conf
