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
| Auth | GitHub OAuth via Supabase Auth | Supabase |
| Rate limiting | Redis | Upstash |
| LLM | Claude Sonnet | Anthropic |
| Embeddings | Voyage AI (voyage-3) | Voyage AI |

## Development — Backend

### Prerequisites

**Tools**

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (local Postgres)
- [uv](https://docs.astral.sh/uv/getting-started/installation/) (Python package manager)

**External services**

The table below lists which services configuration values need to be set for.

| Service | Values needed | Where to find them | Notes |
|---|---|---|---|
| [Supabase](https://supabase.com) | `SUPABASE_URL`<br>`SUPABASE_ANON_KEY`<br>`SUPABASE_JWT_SECRET` | Project Settings → API → "Project URL", "anon public", and "JWT Secret" | Also set up the GitHub OAuth provider under Authentication → Providers. |
| [Anthropic](https://console.anthropic.com) | `ANTHROPIC_API_KEY` | Console → API Keys | Claude Sonnet |
| [Voyage AI](https://dash.voyageai.com) | `VOYAGE_API_KEY` | Dashboard → API Keys | Used for generating embeddings at ingestion time and at query time for research search. |
| [Upstash](https://console.upstash.com) | `UPSTASH_REDIS_REST_URL`<br>`UPSTASH_REDIS_REST_TOKEN` | Select the Redis database → REST API section | Create a Redis database. Used for per-user rate limiting. |
| [Sentry](https://sentry.io) | `SENTRY_DSN` | Project Settings → Client Keys | Create a **Python** project for the backend. |

**User authentication** (GitHub via Supabase Auth)

Create an OAuth app at [github.com/settings/developers](https://github.com/settings/developers). Set the callback URL to the one provided by Supabase (Authentication → Providers → GitHub). Paste the client ID and secret into Supabase. These do not appear in `backend/.env` directly; Supabase holds them.

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

The service is deployed to [Railway](https://railway.app) via `backend/Dockerfile`. All of the variables from `backend/.env.example` need to be set as environment variables in the Railway service dashboard. The service deploys automatically on push/merge to the `main` branch.

### Observability

Errors and performance are tracked via [Sentry](https://sentry.io) (Python SDK). Structured JSON logs include `request_id`, `app_user_id`, and per-phase timing for each analysis request. Token usage (prompt + output) is persisted to the database per message for cost tracking.

## Development — Frontend

*Not yet implemented.*
