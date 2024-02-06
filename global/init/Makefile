.POSIX:
.PHONY: *

default: apply

apply:
	ansible-playbook \
		--inventory hosts.ini \
		--ask-pass \
		main.yaml
