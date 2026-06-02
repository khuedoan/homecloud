.POSIX:
.PHONY: default deploy install test update

default: deploy

HOST = 192.168.1.10

deploy:
	# TODO optimize this
	nixos-rebuild \
		--flake .#tinycloud \
		--target-host root@${HOST} \
		switch

install:
	# TODO migrate to github.com/khuedoan/nixie
	# Currently can't use PXE boot because the stupid hardware
	nixos-anywhere \
		--no-substitute-on-destination \
		--flake .#tinycloud \
		--target-host root@${HOST}

test:
	nixos-rebuild \
		--flake '.#testvm' \
		build-vm
	./result/bin/run-testvm-vm

fmt:
	treefmt

update:
	nix flake update
