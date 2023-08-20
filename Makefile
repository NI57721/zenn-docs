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

