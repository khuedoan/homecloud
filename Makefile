.PHONY: *

default: init images staging production

install:
	sudo nix \
		--experimental-features 'nix-command flakes' \
		run \
		'github:nix-community/disko#disko-install' \
		-- \
		--flake \
		'.#homecloud'

init:
	cd global/init \
		&& ansible-playbook main.yaml

images:
	cd global/images \
		&& make base \
		&& make devbox

global staging production:
	cd ${@} \
		&& tofu init -upgrade \
		&& tofu apply

fmt:
	nixfmt flake.nix metal/*.nix

test:
	@nix \
		--experimental-features 'nix-command flakes' \
		run \
		--impure \
		'.#nixosConfigurations.test.config.system.build.vmWithDisko'
