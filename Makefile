.POSIX:
.PHONY: default deploy vm fmt install test update

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

vm:
	ssh root@${HOST} incus info "${name}" >/dev/null 2>&1 || \
		ssh root@${HOST} incus init --empty --vm "${name}" < "instances/${name}.yaml"

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
