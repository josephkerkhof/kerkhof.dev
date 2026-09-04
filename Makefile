.PHONY: build clean media-check media-prune media-sync media-verify release server worker-dev worker-deploy

HUGO_PARAMS_RELEASE := $(shell git describe --tags --always --dirty)
export HUGO_PARAMS_RELEASE

build: clean
	hugo $(HUGO_ARGS)

clean:
	rm -rf public

media-check:
	bash ./scripts/r2-media.sh check

media-sync:
	bash ./scripts/r2-media.sh sync

media-verify:
	bash ./scripts/r2-media.sh verify-public

media-prune:
	bash ./scripts/r2-media.sh prune-public

release:
	bash ./release.sh "$(VERSION)"

server:
	hugo server -D $(HUGO_ARGS)

worker-dev:
	HUGO_ENVIRONMENT=development HUGO_ENV=development $(MAKE) build
	wrangler dev

worker-deploy: media-sync
	HUGO_ENVIRONMENT=production HUGO_ENV=production $(MAKE) build HUGO_ARGS=--minify
	$(MAKE) media-verify
	$(MAKE) media-prune
	wrangler deploy
