.POSIX:
.PHONY: build serve usb

default: build

xcp-ng-8.2.1-20231130.iso:
	aria2c 'https://mirrors.xcp-ng.org/isos/8.2/xcp-ng-8.2.1-20231130.iso'

data: xcp-ng-8.2.1-20231130.iso
	xorriso -osirrox on -indev $< -extract / $@
	chmod a+w $@ -R
	touch data

build: data
	./build.sh

serve:
	python -m http.server

usb:
	sudo dd bs=4M if=xcp-ng-patched.iso of=${drive} conv=fsync oflag=direct status=progress
