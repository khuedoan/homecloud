.POSIX:
.PHONY: default deploy enroll fmt install test update

default: deploy

HOST = $(shell jq -er '.homecloud.ip' hosts.json)
SSH_KEY = ${HOME}/.ssh/id_ed25519
PXE_ADDRESS = $(shell ip -4 -o address show dev eth0 scope global | awk '{ sub(/\/.*/, "", $$4); print $$4 }')

deploy:
	# TODO optimize this
	nixos-rebuild \
		--flake .#homecloud \
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
	@test -n "${PXE_ADDRESS}" || { \
		echo "eth0 has no IPv4 address" >&2; \
		exit 1; \
	}
	sudo env "PATH=$$PATH" nixie \
		--address "${PXE_ADDRESS}" \
		--installer .#nixosConfigurations.installer \
		--flake . \
		--hosts hosts.json \
		--install-ssh-key "${SSH_KEY}" \
		--deployment-ssh-key "${SSH_KEY}"

test:
	nixos-rebuild \
		--flake '.#testvm' \
		build-vm
	./result/bin/run-testvm-vm

fmt:
	treefmt

update:
	nix flake update
