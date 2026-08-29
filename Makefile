#!/usr/bin/make

export DOCKER_SCAN_SUGGEST = false

ifeq ($(OS), Windows_NT)
	PLATFORM = windows
	NUMBER_OF_LOGICAL_CORES = ${NUMBER_OF_PROCESSORS}
else
	UNAME_S = $(shell uname -s)
	ifeq ($(UNAME_S), Linux)
		PLATFORM = unix
		NUMBER_OF_LOGICAL_CORES = $(shell nproc)
	else ifeq ($(UNAME_S), Darwin)
		PLATFORM = unix
		NUMBER_OF_LOGICAL_CORES = $(shell sysctl -n hw.logicalcpu)
	endif
endif

ifeq ($(PLATFORM), windows)
	SHELL = cmd.exe
	DCEP = dcep
	HELP_SUPPORTED = $(shell where printf 2>&1 >nul && where awk 2>&1 >nul && echo yes)
else
	DCEP = ./dcep
	HELP_SUPPORTED = yes
endif

COMPOSE = docker compose --env-file .env.local

# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## Show this help
ifeq ($(HELP_SUPPORTED), yes)
	@printf "\033[33m%s:\033[0m\n" 'Available commands'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "  \033[32m%-19s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
else
	@echo Add "printf" and "awk" to PATH to display help
endif

.PHONY: create
create: ## Create containers
	$(COMPOSE) build

.PHONY: destroy
destroy: ## Destroy containers
	$(COMPOSE) down --rmi all --volumes --remove-orphans

.PHONY: start
start: ## Start containers
	$(COMPOSE) up --detach --remove-orphans

.PHONY: stop
stop: ## Stop containers
	$(COMPOSE) stop

.PHONY: restart
restart: stop start ## Restart containers

.PHONY: install
install: ## Install all application dependencies
	$(DCEP) composer install --ansi

.PHONY: install-assets
install-assets: ## Install all bundle assets
	$(DCEP) php bin/console assets:install --symlink

.PHONY: first-time-setup
first-time-setup: create start install install-assets ## Run initial setup
# first-time-setup: pull start install install-assets ## Run initial setup

.PHONY: create-project-webapp