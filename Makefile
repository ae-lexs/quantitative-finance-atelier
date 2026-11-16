# Everything runs in Docker. Nothing is installed on the host.

UV_IMAGE := ghcr.io/astral-sh/uv:0.9.5-python3.12-bookworm-slim
# One-off uv container for editing pyproject.toml / uv.lock (no venv needed for that).
UV := docker run --rm -v $(CURDIR):/work -w /work -e UV_PROJECT_ENVIRONMENT=/tmp/venv $(UV_IMAGE) uv

.DEFAULT_GOAL := help
.PHONY: help build up down restart logs shell run python add remove lock clean

help: ## List the available commands
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "} {printf "  make %-10s %s\n", $$1, $$2}'

build: ## Build the image from pyproject.toml + uv.lock
	docker compose build

up: ## Start JupyterLab at http://127.0.0.1:8888/lab
	docker compose up -d --build
	@echo "JupyterLab: http://127.0.0.1:8888/lab"

down: ## Stop JupyterLab
	docker compose down

restart: down up ## Restart JupyterLab

logs: ## Follow the JupyterLab logs
	docker compose logs -f lab

shell: ## Open a bash shell in the container
	docker compose run --rm lab bash

run: ## Run a script: make run SCRIPT=scripts/foo.py
	docker compose run --rm lab python $(SCRIPT)

python: ## Open a Python REPL
	docker compose run --rm lab python

add: ## Add a dependency: make add PKG=yfinance==1.8.0
	$(UV) add --no-sync "$(PKG)"
	docker compose build

remove: ## Remove a dependency: make remove PKG=yfinance
	$(UV) remove --no-sync "$(PKG)"
	docker compose build

lock: ## Regenerate uv.lock from pyproject.toml
	$(UV) lock

clean: ## Stop everything and delete the image
	docker compose down --rmi local
