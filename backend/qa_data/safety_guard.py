"""
SMART-EDU QA SAFETY GUARD MODULE
Bảo vệ cơ sở dữ liệu môi trường Production khỏi các test script phá hủy (destructive tests).

Hướng dẫn chạy test an toàn:
1. Mặc định: Chạy an toàn với CSDL SQLite test nội bộ (backend/language_center.db) hoặc CSDL test riêng.
2. Để chạy với PostgreSQL test cục bộ:
   PowerShell:
     $env:DATABASE_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center_test"
     $env:SMART_EDU_TEST_DB = "1"
     python backend/qa_data/test_class_transfer_suite.py
   Bash:
     export DATABASE_URL="postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center_test"
     export SMART_EDU_TEST_DB=1
     python backend/qa_data/test_class_transfer_suite.py
3. Nghiêm cấm đặt DATABASE_URL trỏ tới máy chủ production hoặc cơ sở dữ liệu thật.
"""

import os
import sys

PROD_IDENTIFIERS = [
    "production", "prod", "live", "main-db", "prod-db",
    "language_center_prod", "smartedu.vn", "aws.com", "rds", "cloud"
]

def is_production_database(db_url: str) -> tuple[bool, str]:
    """Kiểm tra xem URL database hoặc môi trường có phải là Production hay không."""
    env = os.getenv("ENV", os.getenv("ENVIRONMENT", os.getenv("APP_ENV", ""))).strip().lower()
    if env in ("production", "prod", "live"):
        return True, f"Biến môi trường ENV='{env}' được xác định là Production."

    if not db_url:
        return False, ""

    url_lower = db_url.lower()
    for token in PROD_IDENTIFIERS:
        if token in url_lower:
            return True, f"DATABASE_URL chứa từ khóa cấm của Production: '{token}'."

    return False, ""

def validate_test_database_target(is_destructive: bool = True, silent: bool = False):
    """
    Xác minh CSDL mục tiêu trước khi chạy kiểm thử:
    1. Chặn đứng tuyệt đối nếu URL hoặc môi trường là Production.
    2. Nếu là test có hành vi phá hủy (destructive: CREATE/UPDATE/DELETE/TRUNCATE),
       yêu cầu phải chạy trên CSDL kiểm thử (SQLite hoặc PostgreSQL có gắn cờ xác nhận SMART_EDU_TEST_DB=1 / TESTING=1).
    """
    db_url = os.getenv("DATABASE_URL", "")
    is_prod, reason = is_production_database(db_url)
    if is_prod:
        err_msg = (
            "\n" + "=" * 70 + "\n"
            "🚨 CRITICAL QA SAFETY GUARD: BLOCK EXECUTION!\n"
            f"LÝ DO: {reason}\n"
            "Script kiểm thử bị chặn hoàn toàn để bảo vệ cơ sở dữ liệu Production!\n"
            "Không được phép chạy bất kỳ câu lệnh DELETE, UPDATE hoặc COMMIT trên CSDL thật.\n"
            "=" * 70 + "\n"
        )
        if not silent:
            print(err_msg, file=sys.stderr)
        raise RuntimeError(f"Safety Violation: Cannot run test script on Production database! {reason}")

    if is_destructive:
        is_sqlite = db_url.startswith("sqlite") or "sqlite" in db_url
        is_test_flag = os.getenv("SMART_EDU_TEST_DB") == "1" or os.getenv("TESTING") == "1"
        is_test_in_url = "test" in db_url.lower() or "dev" in db_url.lower() or not db_url

        if not (is_sqlite or is_test_flag or is_test_in_url):
            err_msg = (
                "\n" + "=" * 70 + "\n"
                "⚠️ QA SAFETY WARNING: Destructive test requires explicit confirmation!\n"
                "CSDL hiện tại không có hậu tố 'test' hoặc biến SMART_EDU_TEST_DB=1.\n"
                "Vui lòng cấu hình:\n"
                "  $env:SMART_EDU_TEST_DB = '1' (PowerShell)\n"
                "  export SMART_EDU_TEST_DB=1 (Bash)\n"
                "hoặc trỏ DATABASE_URL vào CSDL test an toàn.\n"
                "=" * 70 + "\n"
            )
            if not silent:
                print(err_msg, file=sys.stderr)
            raise RuntimeError("Safety Violation: Explicit test database confirmation required for destructive QA scripts.")
    
    return True
