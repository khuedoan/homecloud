#!/bin/sh

set -eu

patch --forward --reject-file - --input patches/grub.diff data/EFI/xenserver/grub.cfg || true

cd data
OUTPUT=../xcp-ng-patched.iso # TODO
VERSION=8.2 # TODO
genisoimage -o $OUTPUT -v -r -J --joliet-long -V "XCP-ng $VERSION" -c boot/isolinux/boot.cat -b boot/isolinux/isolinux.bin \
            -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/efiboot.img -no-emul-boot .
isohybrid --uefi $OUTPUT
