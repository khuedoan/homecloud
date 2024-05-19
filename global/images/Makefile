.PHONY: *

%:
	rsync --progress --checksum \
		"$(shell nix build --no-link --print-out-paths .\#$@ --show-trace)/tarball/nixos-system-x86_64-linux.tar.xz" \
		root@proxmox:/var/lib/vz/template/cache/nixos-$@.tar.xz
