.POSIX:
.PHONY: default build test diff update install

default: build

build:
	sudo nixos-rebuild \
		--flake '.#${host}' \
		switch

test:
	nixos-rebuild \
		--flake '.#${host}' \
		build-vm
	./result/bin/run-${host}-vm

diff:
	nixos-rebuild \
		--flake '.#${host}' \
		build
	nix store diff-closures \
		--allow-symlinked-store \
		/nix/var/nix/profiles/system ./result

update:
	nix flake update

install:
	# TODO This consumes significant memory on the live USB because
	# dependencies are downloaded to tmpfs. The configuration must be small, or
	# the machine must have a lot of RAM.
	sudo nix \
		--extra-experimental-features 'nix-command flakes' \
		run 'github:nix-community/disko/latest#disko-install' -- \
		--write-efi-boot-entries \
		--flake '.#${host}' \
		--disk main '${disk}'

fmt:
	nixfmt flake.nix metal/*.nix
