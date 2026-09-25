.DEFAULT_GOAL := help

SHELL := bash
.SHELLFLAGS := -o pipefail -ec

# Mirrors bundle.yaml's import graph: root -> sib-a/sib-b -> leaves.
BUNDLES := root sib-a sib-b leaf-root leaf-three leaf-diamond

.PHONY: help
help: ## Show help for common make targets.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) }' $(MAKEFILE_LIST)

##@ Dependencies

.PHONY: deps
deps: ## Install build tooling for every bundle, in dependency order (root, then sib-a/sib-b, then leaves)
	@for b in $(BUNDLES); do $(MAKE) -C $$b deps; done

##@ Bundle

.PHONY: bundle
bundle: ## Bundle every bundle, in dependency order (root, then sib-a/sib-b, then leaves)
	@for b in $(BUNDLES); do $(MAKE) -C $$b bundle; done

##@ Configure

.PHONY: configure
configure: ## Configure every bundle, in dependency order (root, then sib-a/sib-b, then leaves)
	@for b in $(BUNDLES); do $(MAKE) -C $$b configure; done

##@ Test

.PHONY: test
test: configure ## Run configure for every bundle, then diff each config.yaml against test/golden
	@status=0; \
	for b in $(BUNDLES); do \
		if ! diff -u "test/golden/$$b.config.yaml" "$$b/config.yaml"; then \
			echo "$$b/config.yaml does not match test/golden/$$b.config.yaml" >&2; \
			status=1; \
		fi; \
	done; \
	exit $$status

##@ Housekeeping

.PHONY: clean
clean: ## Clean build artifacts in every bundle
	@for b in $(BUNDLES); do $(MAKE) -C $$b clean; done
