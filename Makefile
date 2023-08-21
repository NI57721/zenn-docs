.DEFAULT_GOAL := help
.PHONY: all allinstall

## help: Display this message.
help:
	@grep -P "^## [a-zA-Z_-]+: .[^\n]*$$" $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = "^## |: "}; {printf "\033[36m%-20s\033[0m %s\n", $$2, $$3}'

## init: Initialize npm
init:
	npm install
	npx zenn init

## update: Update required packages of npm
update:
	npm install zenn-cli@latest

## new: Create a new article
new:
	@read -p "Enter Slug:" slug; \
	if [ -n "$$slug" ]; then \
		npx zenn new:article --slug $$slug; \
	else \
		npx zenn new:article; \
	fi

## prev: Show the previews of the articles and watch the update
prev:
	xdg-open http://localhost:8000
	npx zenn preview

