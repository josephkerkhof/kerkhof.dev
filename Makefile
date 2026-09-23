.PHONY: build clean format format-check hooks media-check media-prune media-sync media-verify release server worker-dev worker-deploy

HUGO_PARAMS_RELEASE := $(shell git describe --tags --always --dirty)
export HUGO_PARAMS_RELEASE

build: clean
	hugo $(HUGO_ARGS)

clean:
	rm -rf public

format:
	bash ./scripts/prettier.sh --write '*.md' 'content/**/*.md'

format-check:
	bash ./scripts/prettier.sh --check '*.md' 'content/**/*.md'

hooks:
	bash ./scripts/install-hooks.sh

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
	hugo server -D --renderToMemory --bind 127.0.0.1 --port 1313 --baseURL http://127.0.0.1:1313/ $(HUGO_ARGS)

worker-dev:
	HUGO_ENVIRONMENT=development HUGO_ENV=development $(MAKE) build
	wrangler dev

worker-deploy: media-sync
	HUGO_ENVIRONMENT=production HUGO_ENV=production $(MAKE) build HUGO_ARGS=--minify
	$(MAKE) media-verify
	$(MAKE) media-prune
	wrangler deploy
