.PHONY: build release server

HUGO_PARAMS_RELEASE := $(shell git describe --tags --always --dirty)
export HUGO_PARAMS_RELEASE

build:
	hugo $(HUGO_ARGS)

release:
	bash ./release.sh "$(VERSION)"

server:
	hugo server -D $(HUGO_ARGS)
