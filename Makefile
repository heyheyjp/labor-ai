.PHONY: help \
        setup install-uv install-pnpm install-tools install-deps \
        db-up db-down db-reset db-migrate db-create-migration \
        server-install server-dev server-lint server-lint-fix server-format server-type server-test \
        client-install client-dev client-lint client-type client-test client-format \
        ci-server ci-client

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# ── Bootstrap ────────────────────────────────────────────────────────────────

# 'setup' extends PATH to find uv and pnpm at their default install locations
# immediately after the curl installers run — no shell restart needed.
# Assumes: uv → ~/.local/bin  |  pnpm → ~/Library/pnpm (macOS) or ~/.local/share/pnpm (Linux)
# If either tool lands elsewhere (e.g. custom $PNPM_HOME, Homebrew), use
# make install-tools instead, restart your shell, then run make install-deps.
export PATH := $(HOME)/.local/bin:$(HOME)/.local/share/pnpm:$(HOME)/Library/pnpm:$(PATH)

setup: install-tools install-deps ## One-shot: install tools and all project dependencies

install-uv: ## Install uv Python package manager (macOS / Linux)
	curl -LsSf https://astral.sh/uv/install.sh | sh

install-pnpm: ## Install pnpm package manager (macOS / Linux)
	curl -fsSL https://get.pnpm.io/install.sh | sh -

install-tools: install-uv install-pnpm ## Install prerequisite CLI tools (uv, pnpm) — restart your shell, then run make install-deps
	@echo ""
	@echo "Tools installed. Restart your shell, then run: make install-deps"

install-deps: ## Install all project dependencies (root, server, client)
	pnpm install --frozen-lockfile
	cd backend && uv sync --frozen
	cd frontend && pnpm install --frozen-lockfile

# ── Database ──────────────────────────────────────────────────────────────────

db-up: ## Start local Postgres (pgvector/pgvector:pg16)
	docker compose up -d

db-down: ## Stop local Postgres
	docker compose down

db-reset: ## Destroy volume and recreate DB from scratch
	docker compose down -v
	docker compose up -d

db-migrate: ## Apply Alembic migrations (upgrade head)
	cd backend && uv run alembic upgrade head

db-create-migration: ## Generate a new Alembic migration (usage: make db-create-migration MSG="describe change")
	cd backend && uv run alembic revision --autogenerate -m "$(MSG)"

# ── Server (FastAPI) ──────────────────────────────────────────────────────────

server-install: ## Install server Python deps with uv
	cd backend && uv sync --frozen

server-dev: ## Run FastAPI dev server (hot reload)
	cd backend && uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

server-lint: ## Run ruff check + format check
	cd backend && uv run ruff check . && uv run ruff format --check .

server-lint-fix: ## Auto-fix ruff lint violations in server Python files
	cd backend && uv run ruff check --fix .

server-format: ## Auto-format server Python files with ruff
	cd backend && uv run ruff format .

server-type: ## Run mypy strict type check
	cd backend && uv run mypy app

server-test: ## Run pytest (requires Postgres running)
	cd backend && uv run pytest

# ── Client (Next.js) ──────────────────────────────────────────────────────────

client-install: ## Install client Node deps with pnpm
	cd frontend && pnpm install --frozen-lockfile

client-dev: ## Run Next.js dev server (Turbopack)
	cd frontend && pnpm dev

client-lint: ## Run ESLint
	cd frontend && pnpm lint

client-type: ## Run TypeScript check
	cd frontend && pnpm type-check

client-test: ## Run Vitest (single run, no watch)
	cd frontend && pnpm test

client-format: ## Check Prettier formatting
	cd frontend && pnpm format:check

# ── CI ────────────────────────────────────────────────────────────────────────

ci-server: server-install server-lint server-type server-test ## Full server CI sequence locally

ci-client: client-install client-lint client-type client-test ## Full client CI sequence locally
