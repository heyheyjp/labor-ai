.PHONY: help up down db-reset \
        backend-install backend-dev backend-lint backend-lint-fix backend-format backend-type backend-test backend-migrate backend-migration \
        frontend-install frontend-dev frontend-lint frontend-type frontend-test frontend-format \
        ci-backend ci-frontend

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# ── Docker ───────────────────────────────────────────────────────────────────

up: ## Start local Postgres (pgvector/pgvector:pg16)
	docker compose up -d

down: ## Stop local Postgres
	docker compose down

db-reset: ## Destroy volume and recreate DB from scratch
	docker compose down -v
	docker compose up -d

# ── Backend ──────────────────────────────────────────────────────────────────

backend-install: ## Install backend Python deps with uv
	cd backend && uv sync --frozen

backend-dev: ## Run FastAPI dev server (hot reload)
	cd backend && uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

backend-lint: ## Run ruff check + format check
	cd backend && uv run ruff check . && uv run ruff format --check .

backend-lint-fix: ## Auto-fix ruff lint violations in backend Python files
	cd backend && uv run ruff check --fix .

backend-format: ## Auto-format backend Python files with ruff
	cd backend && uv run ruff format .

backend-type: ## Run mypy strict type check
	cd backend && uv run mypy app

backend-test: ## Run pytest (requires Postgres running)
	cd backend && uv run pytest

backend-migrate: ## Apply Alembic migrations (upgrade head)
	cd backend && uv run alembic upgrade head

backend-migration: ## Generate a new Alembic migration (usage: make backend-migration MSG="describe change")
	cd backend && uv run alembic revision --autogenerate -m "$(MSG)"

# ── Frontend ─────────────────────────────────────────────────────────────────

frontend-install: ## Install frontend Node deps with pnpm
	cd frontend && pnpm install --frozen-lockfile

frontend-dev: ## Run Next.js dev server (Turbopack)
	cd frontend && pnpm dev

frontend-lint: ## Run ESLint
	cd frontend && pnpm lint

frontend-type: ## Run TypeScript check
	cd frontend && pnpm type-check

frontend-test: ## Run Vitest (single run, no watch)
	cd frontend && pnpm test:run

frontend-format: ## Check Prettier formatting
	cd frontend && pnpm format:check

# ── Combined ─────────────────────────────────────────────────────────────────

ci-backend: backend-install backend-lint backend-type backend-test ## Full backend CI sequence locally

ci-frontend: frontend-install frontend-lint frontend-type frontend-test ## Full frontend CI sequence locally
