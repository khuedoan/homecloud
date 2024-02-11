.POSIX:
.PHONY: *

default: staging

global staging production:
	cd ${@} && tofu apply
