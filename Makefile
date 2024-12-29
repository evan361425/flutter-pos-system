SHELL := /usr/bin/env bash -o errexit -o pipefail -o nounset

.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-23s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development
.PHONY: format
format: ## Format code
	dart format --set-exit-if-changed --line-length 120 .

.PHONY: lint
lint: ## Lint code
	flutter analyze .

.PHONY: outdated
outdated: ## Find outdated dependencies
	flutter pub outdated --no-transitive --no-prereleases

.PHONY: test
test: ## Run tests
	flutter test

.PHONY: test-coverage
test-coverage: ## Run tests with coverage
	flutter test --coverage
	@genhtml coverage/lcov.info -o coverage/html
	@open coverage/html/index.html

##@ Bump
.PHONY: bump-dev
bump-dev: ## Bump development version
	@current=$$(grep '^version:' pubspec.yaml | head -n1 | cut -d' ' -f2 | cut -d'+' -f1); \
	read -p "Enter new version (empty means bump build code only, current is $$current): " version; \
	if [[ -n $$version ]]; then \
		if [[ ! $$version =~ ^[0-9]+\.[0-9]+\.[0-9]+$$ ]]; then \
			echo "Version must be in x.x.x format"; \
			exit 1; \
		fi; \
		if [[ $$(echo -e "$$version\n$$current" | sort -V | head -n1) == $$version ]]; then \
			echo "Version must be above $$current"; \
			exit 1; \
		fi; \
		code="$$(echo $$version | cut -d'.' -f1)$$(printf "%02d" $$(echo $$version | cut -d'.' -f2))"; \
		code="$$code$$(printf "%02d" $$(echo $$version | cut -d'.' -f3))001"; \
	else \
		version=$$current; \
		code=$$(grep '^version:' pubspec.yaml | head -n1 | cut -d' ' -f2 | cut -d'+' -f2); \
		code=$$(($$code + 1)); \
	fi; \
	sed -i.bk '5s/version: .*/version: '$$version+$$code'/' pubspec.yaml; \
	rm pubspec.yaml.bk; \
	git add pubspec.yaml; \
	git commit -m "chore: bump to $$version+$$code"; \
	id=$$( echo "$$code" | awk '{print substr($$0,length($$0)-2)}' | awk '{$$1=$$1+0; print}' ); \
	git tag "v$$version-rc$$id"; \
	git push; \
	git push --tags

.PHONY: bump
bump: ## Bump beta version
	@version=$$(grep '^version:' pubspec.yaml | head -n1 | cut -d' ' -f2 | cut -d'+' -f1); \
	read -p "This will bump to beta lane, are you sure? (y/n): " confirm; \
	if [[ $$confirm != "y" ]]; then exit 1; fi; \
	code=$$(grep '^version:' pubspec.yaml | head -n1 | cut -d' ' -f2 | cut -d'+' -f2); \
	code=$$(($$code + 1)); \
	sed -i.bk '5s/version: .*/version: '$$version+$$code'/' pubspec.yaml; \
	rm pubspec.yaml.bk; \
	bash scripts/bump-after.sh v$$version $$code; \
	read -p "Are you satisfied with the changes? (y/n): " confirm; \
	if [[ $$confirm != "y" ]]; then exit 1; fi; \
	git add .; \
	git commit -m "chore: bump to $$version+$$code"; \
	git tag "v$$version"; \
	git push; \
	git push --tags

##@ Tools
.PHONY: build-mock
build-mock: ## Mock dependencies
	dart run build_runner build --delete-conflicting-outputs
	dart format --line-length 120 .

.PHONY: build-l10n
build-l10n: ## Build localization
	dart run arb_glue
	flutter pub get --no-example

.PHONY: clean-version
clean-version: ## Clean beta and rc version
	@git pull
	@git tag -l | grep -E 'beta|rc' | xargs git push --delete origin
	@git tag -l | grep -E 'beta|rc' | xargs git tag -d
