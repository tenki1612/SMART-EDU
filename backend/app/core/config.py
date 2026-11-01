import os
from pathlib import Path
from typing import List
from pydantic import field_validator
from pydantic_settings import BaseSettings

_BASE_DIR = Path(__file__).resolve().parent.parent.parent
_DEFAULT_DB = _BASE_DIR / "language_center.db"

class Settings(BaseSettings):
    PROJECT_NAME: str = "Language Center Management System (Hệ thống Quản lý Trung tâm Ngoại ngữ)"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "super-secret-key-change-in-production-language-center-2026"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 1 day
    
    # SQLite default pointing reliably to backend/language_center.db
    DATABASE_URL: str = f"sqlite:///{_DEFAULT_DB.as_posix()}"
    
    @field_validator("DATABASE_URL", mode="before")
    @classmethod
    def sanitize_database_url(cls, v):
        # Bỏ qua nếu là URL dạng Prisma "file:./dev.db" để tránh lỗi SQLAlchemy
        if isinstance(v, str) and (v.startswith("file:") or not v.strip()):
            return f"sqlite:///{_DEFAULT_DB.as_posix()}"
        return v
    
    # CORS
    BACKEND_CORS_ORIGINS: List[str] = ["http://localhost:5173", "http://localhost:3000", "http://127.0.0.1:5173", "*"]

    class Config:
        case_sensitive = True
        env_file = str(_BASE_DIR / ".env")

settings = Settings()
