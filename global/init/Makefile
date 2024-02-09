.POSIX:
.PHONY: *

default: apply

apply:
	ansible-playbook \
		--inventory hosts.ini \
		--ask-pass \
		main.yaml

console:
	ansible-console \
		--inventory hosts.ini \
		--ask-pass
