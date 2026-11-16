import os
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from app.core.config import settings
from app.core.database import engine, Base
import app.models # Register all models
from app.api.v1.api import api_router

# Auto-create tables on launch if not exists
Base.metadata.create_all(bind=engine)

def ensure_schema():
    """Ensure newly added columns exist in SQLite database"""
    with engine.connect() as conn:
        try:
            res = conn.exec_driver_sql("PRAGMA table_info(users)").fetchall()
            existing_cols = {row[1] for row in res}
            if "failed_login_attempts" not in existing_cols:
                conn.exec_driver_sql("ALTER TABLE users ADD COLUMN failed_login_attempts INTEGER DEFAULT 0 NOT NULL")
            if "locked_until" not in existing_cols:
                conn.exec_driver_sql("ALTER TABLE users ADD COLUMN locked_until DATETIME")
            if "reset_token" not in existing_cols:
                conn.exec_driver_sql("ALTER TABLE users ADD COLUMN reset_token VARCHAR(100)")
            if "reset_token_expires_at" not in existing_cols:
                conn.exec_driver_sql("ALTER TABLE users ADD COLUMN reset_token_expires_at DATETIME")
            if "avatar_url" not in existing_cols:
                conn.exec_driver_sql("ALTER TABLE users ADD COLUMN avatar_url VARCHAR(500)")
            conn.commit()
        except Exception:
            pass

ensure_schema()

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Hệ thống Web Quản lý Trung tâm Ngoại ngữ - Kiến trúc Modular Monolith chuẩn công nghiệp với 82 chức năng nghiệp vụ.",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json"
)

# Static Uploads directory
UPLOAD_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "uploads")
os.makedirs(os.path.join(UPLOAD_DIR, "avatars"), exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Standardized Error Handlers
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = exc.errors()
    error_msg = errors[0].get("msg") if errors else "Lỗi xác thực dữ liệu đầu vào"
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "success": False,
            "code": "VALIDATION_ERROR",
            "message": f"Dữ liệu không hợp lệ: {error_msg}",
            "data": errors
        }
    )

# Include All Routers
app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/", tags=["Health Check"])
def health_check():
    return {
        "status": "healthy",
        "system": settings.PROJECT_NAME,
        "docs": "/docs",
        "api_v1": settings.API_V1_STR
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
