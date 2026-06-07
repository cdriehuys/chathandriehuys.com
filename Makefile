.PHONY: default
default: build

.PHONY: build
build:
	hugo

.PHONY: clean
clean:
	rm -r public
	rm -r resources
	rm hugo_stats.json

.PHONY: dev
dev:
	hugo server --buildDrafts
