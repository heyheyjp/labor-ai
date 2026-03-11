"""create app_user table

Revision ID: 0001
Revises:
Create Date: 2026-03-10

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "0001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Enable pgvector extension — required for later phases (research_chunk embeddings)
    op.execute("CREATE EXTENSION IF NOT EXISTS vector")

    op.create_table(
        "app_user",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            server_default=sa.text("gen_random_uuid()"),
            nullable=False,
        ),
        sa.Column("supabase_user_id", sa.String(), nullable=False),
        sa.Column("github_user_id", sa.String(), nullable=False),
        sa.Column("github_username", sa.String(), nullable=False),
        sa.Column(
            "created_at_utc",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.Column(
            "updated_at_utc",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("supabase_user_id", name="uq_app_user_supabase_user_id"),
        sa.UniqueConstraint("github_user_id", name="uq_app_user_github_user_id"),
    )


def downgrade() -> None:
    op.drop_table("app_user")
    op.execute("DROP EXTENSION IF EXISTS vector")
