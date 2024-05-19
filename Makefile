.POSIX:
.PHONY: *

default: init global staging production

init:
	cd global/init \
		&& ansible-playbook main.yaml

global staging production:
	cd ${@} \
		&& tofu init -upgrade \
		&& tofu apply
