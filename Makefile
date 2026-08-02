.POSIX:
.PHONY: default deploy enroll install test update

default: deploy

HOST = 192.168.1.10

deploy:
	# TODO optimize this
	nixos-rebuild \
		--flake .#tinycloud \
		--target-host root@${HOST} \
		switch

enroll:
	@ssh -t root@${HOST} '\
		set -eu; \
		password=$$(sudo -u kanidm kanidmd scripting recover-account \
			-c /etc/kanidm/server.toml idm_admin | jq -er .output); \
		trap "kanidm logout -D idm_admin || true" EXIT; \
		KANIDM_PASSWORD="$$password" kanidm login -D idm_admin; \
		kanidm person credential create-reset-token -D idm_admin "${username}" \
	'

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
