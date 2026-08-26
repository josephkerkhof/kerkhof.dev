.PHONY: build server

HUGO_PARAMS_RELEASE := $(shell git describe --tags --always --dirty)
export HUGO_PARAMS_RELEASE

build:
	hugo $(HUGO_ARGS)

server:
	hugo server -D $(HUGO_ARGS)
