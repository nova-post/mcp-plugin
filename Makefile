NAME    := $(shell jq -r .name plugin.json)
VERSION := $(shell jq -r .version plugin.json)
ZIP     := dist/$(NAME)-$(VERSION).zip
CLAUDE  ?= claude

.PHONY: zip validate release release-dry-run clean

# Only files committed in HEAD; uncommitted changes are not packed.
zip:
	@git diff --quiet HEAD -- || echo "warning: uncommitted changes are not included in $(ZIP)" >&2
	@mkdir -p dist
	git archive --format=zip --output=$(ZIP) HEAD
	@echo $(ZIP)

validate:
	$(CLAUDE) plugin validate . --profile directory

# Publishes origin/master to origin/main as one release commit (see RELEASING.md).
release:
	bash scripts/release.sh

release-dry-run:
	bash scripts/release.sh --dry-run

clean:
	rm -rf dist
