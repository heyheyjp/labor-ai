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

## Prerequisites

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) if not already installed (required locally for the Postgres database).

2. Run the setup command, which will install CLI tools ([uv](https://docs.astral.sh/uv/), [pnpm](https://pnpm.io/)) and project dependencies:

    ```bash
    make setup
    ```

## Configuration

### Backend

1. Copy the example config file:

    ```bash
    cp backend/.env.example backend/.env
    ```

2. Retrieve the values needed to configure your local environment for integration with external services, and save them in the copied config file:

    | Service | Values needed | Where to find them | Notes |
    |---|---|---|---|
    | [Supabase](https://supabase.com) | `SUPABASE_URL`<br>`SUPABASE_ANON_KEY`<br>`SUPABASE_JWT_SECRET` | Project Settings → API → "Project URL", "anon public", and "JWT Secret" | Also set up the GitHub OAuth provider under Authentication → Providers. |
    | [Anthropic](https://console.anthropic.com) | `ANTHROPIC_API_KEY` | Console → API Keys | Claude Sonnet |
    | [Voyage AI](https://dash.voyageai.com) | `VOYAGE_API_KEY` | Dashboard → API Keys | Used for generating embeddings at ingestion time and at query time for research search. |
    | [Upstash](https://console.upstash.com) | `UPSTASH_REDIS_REST_URL`<br>`UPSTASH_REDIS_REST_TOKEN` | Select the Redis database → REST API section | Create a Redis database. Used for per-user rate limiting. |
    | [Sentry](https://sentry.io) | `SENTRY_DSN` | Project Settings → Client Keys | Create a **Python** project for the backend. |

### Frontend

1. Copy the example config file:

    ```bash
    cp frontend/.env.local.example frontend/.env.local
    ```

2. Retrieve the values needed to configure your local environment for integration with external services, and save them in the copied config file:

    | Service | Values needed | Where to find them | Notes |
    |---|---|---|---|
    | [Supabase](https://supabase.com) | `NEXT_PUBLIC_SUPABASE_URL`<br>`NEXT_PUBLIC_SUPABASE_ANON_KEY` | Project Settings → API → "Project URL" and "anon public" | Same Supabase project as the backend. |
    | [Sentry](https://sentry.io) | `NEXT_PUBLIC_SENTRY_DSN` | Project Settings → Client Keys | Create a **Next.js** project for the frontend (separate from the backend Python project). |

## Databases

### Postgres: initializing the database

1. With Docker running, start the local Postgres db:

    ```bash
    make db-up
    ```

2. Run the db migrations

    ```bash
    make db-migrate
    ```

### Postgres: creating a migration

```bash
make db-create-migration MSG="describe what changed"
# review the generated file in backend/migrations/versions/
make db-migrate
```

## Running the apps

### Backend

To start the API service:

```bash
make server-dev
```

The service is listening at http://localhost:8000.

API docs are served at [http://localhost:8000/docs](http://localhost:8000/docs).

### Frontend

To start the dev server for the web app:

```bash
make client-dev
```

The app is served at http://localhost:3000.

## Code quality checks

### Backend

Commands for linting, formatting, type-checking, and testing:
```bash
make server-lint   # ruff check
make server-format # format check
make server-type   # mypy (strict)
make server-test   # pytest (requires Docker DB running)
```

To run them all:

```bash
make ci-server
```

### Frontend

Commands for linting, formatting, type-checking, and testing:
```bash
make client-lint    # ESLint
make client-type    # TypeScript (tsc --noEmit)
make client-test    # Vitest
make client-format  # Prettier format check
```

To run them all:

```bash
make ci-client
```

## CI/CD

### Backend

The FastAPI service is automatically deployed to the production [Railway](https://railway.app) project on push/merge to the `main` branch.

### Frontend

The Next.js app is automatically deployed to the production [Vercel](https://vercel.com) project on push/merge to the `main` branch.

## Observability

### Backend

Errors and performance are tracked via [Sentry](https://sentry.io) (Python SDK). Structured JSON logs include `request_id`, `app_user_id`, and per-phase timing for each analysis request. Token usage (prompt + output) is persisted to the database per message for cost tracking.

### Frontend

--