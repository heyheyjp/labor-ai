from pydantic import AnyHttpUrl, PostgresDsn
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    # Database
    database_url: PostgresDsn

    # Supabase
    supabase_url: AnyHttpUrl
    supabase_anon_key: str
    supabase_jwt_secret: str

    # Anthropic
    anthropic_api_key: str = ""

    # Other services
    voyage_api_key: str = ""
    upstash_redis_rest_url: str = ""
    upstash_redis_rest_token: str = ""
    sentry_dsn: str = ""

    # App
    environment: str = "development"
    allowed_origins: str = "http://localhost:3000"

    @property
    def allowed_origins_list(self) -> list[str]:
        return [origin.strip() for origin in self.allowed_origins.split(",")]

    @property
    def is_production(self) -> bool:
        return self.environment == "production"


settings = Settings()
