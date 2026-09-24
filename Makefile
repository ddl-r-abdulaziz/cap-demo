.DEFAULT_GOAL := help

SHELL := bash
.SHELLFLAGS := -o pipefail -ec

# Mirrors bundle.yaml's import graph: root -> sib-a/sib-b -> leaves.
BUNDLES := root sib-a sib-b leaf-root leaf-three leaf-diamond

# Each bundle's own Makefile defaults BUNDLE_BINARY_SRC to ../bundle, which is
# only correct when that bundle is checked out standalone as a sibling of
# ../bundle. Nested here under cap-demo, that resolves to cap-demo/bundle
# instead - so override it for every sub-make call with the correct path.
BUNDLE_BINARY_SRC ?= $(abspath ../bundle)

.PHONY: help
help: ## Show help for common make targets.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) }' $(MAKEFILE_LIST)

##@ Dependencies

.PHONY: deps
deps: ## Install build tooling for every bundle, in dependency order (root, then sib-a/sib-b, then leaves)
	@for b in $(BUNDLES); do $(MAKE) -C $$b deps BUNDLE_BINARY_SRC=$(BUNDLE_BINARY_SRC); done

##@ Bundle

.PHONY: bundle
bundle: ## Bundle every bundle, in dependency order (root, then sib-a/sib-b, then leaves)
	@for b in $(BUNDLES); do $(MAKE) -C $$b bundle BUNDLE_BINARY_SRC=$(BUNDLE_BINARY_SRC); done

##@ Housekeeping

.PHONY: clean
clean: ## Clean build artifacts in every bundle
	@for b in $(BUNDLES); do $(MAKE) -C $$b clean BUNDLE_BINARY_SRC=$(BUNDLE_BINARY_SRC); done
