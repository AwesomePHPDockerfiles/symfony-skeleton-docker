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

DCEPCT = $(DCEP) bin/console --env=test

COMPOSE = docker compose --env-file .env.local

XDEBUG = @docker compose exec -u root php php docker/php/xdebug/xdebug.php

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

# .PHONY: pull
# pull: ## Pull fresh code from remote repository
# 	git pull
# 	git submodule update --init --recursive

.PHONY: install
install: ## Install all application dependencies
	$(DCEP) composer install --ansi

.PHONY: install-assets
install-assets: ## Install all bundle assets
	$(DCEP) php bin/console assets:install --symlink

.PHONY: first-time-setup
first-time-setup: create start install install-assets ## Run initial setup
# first-time-setup: pull start install install-assets ## Run initial setup

# .PHONY: php-cs-fixer
# php-cs-fixer: ## Run PHP Coding Standards Fixer in analyze mode
# 	$(DCEP) ./docker/php/php-cs-fixer fix --verbose --allow-risky=yes --dry-run

# .PHONY: php-cs-fixer-fix
# php-cs-fixer-fix: ## Run PHP Coding Standards Fixer in fix mode
# 	$(DCEP) ./docker/php/php-cs-fixer fix --verbose --allow-risky=yes

# .PHONY: php-codesniffer
# php-codesniffer: ## Run PHP CodeSniffer in analyze mode
# 	$(DCEP) ./docker/php/phpcs --standard='php-codesniffer.xml'

# .PHONY: php-codesniffer-fix
# php-codesniffer-fix: ## Run PHP CodeSniffer in fix mode
# 	$(DCEP) ./docker/php/phpcbf --standard='php-codesniffer.xml'

# .PHONY: psalm
# psalm: ## Run Psalm in analyze mode
# 	$(DCEP) ./docker/php/psalm $(NUMBER_OF_LOGICAL_CORES) --diff

# .PHONY: psalm-fix
# psalm-fix: ## Run Psalm in fix mode (DANGEROUS: can delete your code)
# 	$(DCEP) ./docker/php/psalm $(NUMBER_OF_LOGICAL_CORES) --alter --issues=all

# .PHONY: analyze
# analyze: php-cs-fixer php-codesniffer psalm ## Run all coding standard checkers, static analyzers etc

# .PHONY: fix
# fix: php-cs-fixer-fix php-codesniffer-fix ## Attempt to fix coding standard violations, static analyzer errors etc

# .PHONY: test
# test: drop-test-db create-test-db migrate-test-db fixtures-load-test-db run-phpunit drop-test-db

# .PHONY: drop-test-db
# drop-test-db: ## drop test DB
# 	$(DCEPCT) doctrine:database:drop --force --if-exists

# .PHONY: create-test-db
# create-test-db: ## create test DB
# 	$(DCEPCT) doctrine:database:create --no-interaction

# .PHONY: migrate-test-db
# migrate-test-db: ## migrate test DB
# 	$(DCEPCT) doctrine:migrations:migrate --no-interaction

# .PHONY: fixtures-load-test-db
# fixtures-load-test-db: ## fixtures loading into test db
# 	$(DCEPCT) hautelook:fixtures:load --no-interaction

# .PHONY: run-phpunit
# run-phpunit:
# 	$(DCEP) vendor/bin/phpunit

.PHONY: xdebug-status
xdebug-status: ## Show Xdebug status
	$(XDEBUG) status

.PHONY: xdebug-enable
xdebug-enable: ## Enable Xdebug
	$(XDEBUG) enable
	$(COMPOSE) restart php
	$(XDEBUG) status

.PHONY: xdebug-disable
xdebug-disable: ## Disable Xdebug
	$(XDEBUG) disable
	$(COMPOSE) restart php
	$(XDEBUG) status

# работает не совсем так, как надо: меняет .env.dev.local вместо .env.local
# .PHONY: generate-secret
# generate-secret: ## Fill APP_SECRET in .env.local with a random cryptographic string
# 	$(DCEP) bash -c 'php -r "print bin2hex(random_bytes(16));" | php bin/console secrets:set APP_SECRET --local'
