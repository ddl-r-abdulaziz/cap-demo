.DEFAULT_GOAL := help

SHELL := bash
.SHELLFLAGS := -o pipefail -ec

# Mirrors bundle.yaml's import graph: root -> sib-a/sib-b -> leaves.
BUNDLES := root sib-a sib-b leaf-root leaf-three leaf-diamond

.PHONY: help
help: ## Show help for common make targets.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) }' $(MAKEFILE_LIST)

##@ Bundle

# One target per bundle, prerequisites matching each bundle.yaml's `import:`
# so root always builds before sib-a/sib-b/leaf-root, and sib-a/sib-b always
# build before the leaves that import them.
.PHONY: bundle-root bundle-sib-a bundle-sib-b bundle-leaf-root bundle-leaf-three bundle-leaf-diamond

bundle-root: ## Bundle root
	$(MAKE) -C root bundle

bundle-sib-a: bundle-root ## Bundle sib-a (depends on root)
	$(MAKE) -C sib-a bundle

bundle-sib-b: bundle-root ## Bundle sib-b (depends on root)
	$(MAKE) -C sib-b bundle

bundle-leaf-root: bundle-root ## Bundle leaf-root (depends on root)
	$(MAKE) -C leaf-root bundle

bundle-leaf-three: bundle-sib-b ## Bundle leaf-three (depends on sib-b)
	$(MAKE) -C leaf-three bundle

bundle-leaf-diamond: bundle-sib-a bundle-sib-b ## Bundle leaf-diamond (depends on sib-a and sib-b)
	$(MAKE) -C leaf-diamond bundle

.PHONY: bundle
bundle: bundle-root bundle-sib-a bundle-sib-b bundle-leaf-root bundle-leaf-three bundle-leaf-diamond ## Bundle every bundle in dependency order (root, then sib-a/sib-b, then leaves)

##@ Housekeeping

.PHONY: clean
clean: ## Clean build artifacts in every bundle
	@for b in $(BUNDLES); do $(MAKE) -C $$b clean; done
