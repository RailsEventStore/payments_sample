setup: ## Install packages and run mgirations
	@bin/setup

web: ## Rails server
	@bin/rails s

css: ## CSS watcher
	@bin/rails tailwindcss:watch

dev: ## Run Rails server and CSS watcher
	@make -j 16 web css

test: ## Run tests
	@bin/rails test

mutate: ## Run mutant
	@bundle exec mutant run

console: ## Rails console
	@bin/rails c

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = "(:|:[^:]*?## )"}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' | sort

.PHONY: help web css dev test mutate console
.DEFAULT_GOAL := help
