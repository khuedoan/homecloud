.POSIX:
.PHONY: *

default: plan

plan:
	cd ${env} && tofu init && tofu $@

apply:
	cd ${env} && tofu init && tofu $@
