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

COMPOSE = docker compose

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

.PHONY: first-time-setup
first-time-setup: create start ## Run initial setup

.PHONY: create-project
create-project: ## Create a new project for building a microservice, console application or API
	@if [ -z "$(PROJECT_DIR)" ]; then \
		echo "PROJECT_DIR is not set. Use: make create-project PROJECT_DIR=<value>."; \
		exit 1; \
	fi

	$(DCEP) bash -c "\
		set -eux && \
		composer create-project symfony/skeleton:'8.1.*' $(PROJECT_DIR) && \
		cp -R ../../project_docker_files/. $(PROJECT_DIR)/ \
	"

.PHONY: create-project-webapp
create-project-webapp: ## Create a new project for building a traditional web application
	@if [ -z "$(PROJECT_DIR)" ]; then \
		echo "PROJECT_DIR is not set. Use: make create-project-webapp PROJECT_DIR=<value>."; \
		exit 1; \
	fi

	$(DCEP) bash -c "\
		set -eux && \
		composer create-project symfony/skeleton:'8.1.*' $(PROJECT_DIR) && \
		cd $(PROJECT_DIR) && \
		composer require webapp && \
		cp -R ../../project_docker_files/. $(PROJECT_DIR)/ \
	"
