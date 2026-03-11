# syntax=docker/dockerfile:1

# ── Build stage ───────────────────────────────────────────────────────────────
FROM python:3.12-slim AS builder

WORKDIR /app

# Install uv from its official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy dependency files first (maximises Docker layer cache)
COPY pyproject.toml uv.lock ./

# Install dependencies into /app/.venv, excluding the project itself and dev deps
RUN uv sync --frozen --no-install-project --no-dev

# Copy source and install the project package
COPY app/ ./app/
RUN uv sync --frozen --no-dev

# ── Runtime stage ─────────────────────────────────────────────────────────────
FROM python:3.12-slim AS runtime

WORKDIR /app

# Copy only the virtualenv and app code from builder
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/app /app/app

# Put the venv on PATH so uvicorn and app packages are found
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
