.POSIX:
.PHONY: *

default: plan

init:
	cd ${env} && tofu $@ -upgrade

plan:
	cd ${env} && tofu $@

apply:
	cd ${env} && tofu $@
