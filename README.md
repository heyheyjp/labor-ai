# labor-ai

## Overview

Labor & AI is a labor market intelligence web app that helps people understand how AI is reshaping their specific occupation. Users search for their job, get an instant AI-generated analysis grounded in BLS and Pew research data, and can ask follow-up questions conversationally.

The core value prop: answers about automation risk, job growth, and wages in plain English with inline citations to real research.

## Stack

| Layer | Technology | Host |
|---|---|---|
| Frontend | Next.js 15, React 19, TypeScript, Tailwind CSS v4 | Vercel |
| Backend | FastAPI, Python 3.12 | Railway |
| Database | Postgres 16 + pgvector | Supabase |
| Auth | GitHub OAuth via Supabase Auth | — |
| Rate limiting | Upstash Redis | Upstash |
| LLM | Anthropic Claude Sonnet | Anthropic |
| Embeddings | Voyage AI (voyage-3) | Voyage AI |

## Development — Backend

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) — local Postgres
- [uv](https://docs.astral.sh/uv/getting-started/installation/) — Python package manager (`curl -LsSf https://astral.sh/uv/install.sh | sh`)

### First-time setup

**1. Start the local database**

```bash
make up
```

This starts a `pgvector/pgvector:pg16` container (`labor_ai_db`) with the database `labor_ai` on port 5432.

**2. Configure environment variables**

```bash
cp backend/.env.example backend/.env
```

Fill in at minimum:
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_JWT_SECRET` — from your Supabase project settings

`DATABASE_URL` is pre-filled for the local Docker container and works as-is. Other keys (`ANTHROPIC_API_KEY`, etc.) can be left blank until those features are needed.

**3. Install dependencies and run migrations**

```bash
make backend-install
make backend-migrate
```

### Running locally

```bash
make backend-dev    # FastAPI on http://localhost:8000
```

API docs are available at [http://localhost:8000/docs](http://localhost:8000/docs) in development.

### Code quality

```bash
make backend-lint   # ruff check + format check
make backend-type   # mypy (strict)
make backend-test   # pytest (requires Docker DB running)
```

Or run the full CI sequence in one shot:

```bash
make ci-backend
```

### Database migrations

```bash
make backend-migration MSG="describe what changed"
# review the generated file in backend/migrations/versions/
make backend-migrate
```

### Deployment

Deployed to [Railway](https://railway.app) via `backend/Dockerfile`. Set all variables from `backend/.env.example` as environment variables in the Railway service dashboard. The service deploys automatically on push to `main`.

### Observability

Errors and performance are tracked via [Sentry](https://sentry.io) (Python SDK). Structured JSON logs include `request_id`, `app_user_id`, and per-phase timing for each analysis request. Token usage (prompt + output) is persisted to the database per message for cost tracking.

## Development — Frontend

*Not yet implemented.*

## More Docs
