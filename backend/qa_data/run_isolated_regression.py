import os
import sys
import shutil
import subprocess

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_DB = os.path.join(BASE_DIR, "language_center.db")
ISO_DB = os.path.join(BASE_DIR, "qa_data", "isolated_regression_runner.db")

print("======================================================================")
print("RUNNING REGRESSION SUITES ON ISOLATED TEST DATABASE")
print("======================================================================")
print(f"Source DB: {SRC_DB}")
print(f"Isolated Test DB: {ISO_DB}")

# Create isolated copy
shutil.copyfile(SRC_DB, ISO_DB)
iso_url = f"sqlite:///{ISO_DB.replace(os.sep, '/')}"

env = os.environ.copy()
env["DATABASE_URL"] = iso_url
env["QA_TEST_RUNNER"] = "1"

results = {}

# 1. test_api.py (Full regression: 121 tests)
print("\n>>> 1. Running backend/test_api.py on isolated DB...")
p1 = subprocess.run([sys.executable, "backend/test_api.py"], env=env, capture_output=True, text=True)
results["test_api"] = (p1.returncode == 0, p1.stdout[-300:] if p1.stdout else p1.stderr[-300:])
print(f"test_api.py: {'PASSED' if p1.returncode == 0 else 'FAILED'}")

# 2. test_class_transfer_suite.py (BUG-01 & BUG-02: 31 tests)
print("\n>>> 2. Running test_class_transfer_suite.py on isolated DB...")
p2 = subprocess.run([sys.executable, "backend/qa_data/test_class_transfer_suite.py"], env=env, capture_output=True, text=True)
results["test_class_transfer"] = (p2.returncode == 0, p2.stdout[-300:] if p2.stdout else p2.stderr[-300:])
print(f"test_class_transfer_suite.py: {'PASSED' if p2.returncode == 0 else 'FAILED'}")

# 3. test_parent_inbox_idor_suite.py (BUG-03: 11 tests)
print("\n>>> 3. Running test_parent_inbox_idor_suite.py on isolated DB...")
p3 = subprocess.run([sys.executable, "backend/qa_data/test_parent_inbox_idor_suite.py"], env=env, capture_output=True, text=True)
results["test_parent_inbox_idor"] = (p3.returncode == 0, p3.stdout[-300:] if p3.stdout else p3.stderr[-300:])
print(f"test_parent_inbox_idor_suite.py: {'PASSED' if p3.returncode == 0 else 'FAILED'}")

# 4. test_timetable_sync_suite.py (Timetable suite: 29 tests)
print("\n>>> 4. Running test_timetable_sync_suite.py on isolated DB...")
p4 = subprocess.run([sys.executable, "backend/qa_data/test_timetable_sync_suite.py"], env=env, capture_output=True, text=True)
results["test_timetable_sync"] = (p4.returncode == 0, p4.stdout[-300:] if p4.stdout else p4.stderr[-300:])
print(f"test_timetable_sync_suite.py: {'PASSED' if p4.returncode == 0 else 'FAILED (Expected 4 investigated assertions)'}")

# Cleanup isolated DB
if os.path.exists(ISO_DB):
    try:
        os.remove(ISO_DB)
        print(f"\n✓ Cleaned up isolated test database: {ISO_DB}")
    except Exception as e:
        print(f"Note: Could not remove test DB: {e}")

print("\n======================================================================")
print("REGRESSION SUMMARY")
print("======================================================================")
for k, (ok, out) in results.items():
    print(f"- {k}: {'PASSED' if ok else 'FAILED'}")
