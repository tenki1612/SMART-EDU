import requests
import jwt
import sys
sys.path.insert(0, ".")
from app.core.config import settings

BASE_URL = "http://127.0.0.1:8000/api/v1"

res = requests.post(f"{BASE_URL}/auth/login", json={"username": "staff", "password": "staff123"})
print("Status:", res.status_code)
print("Response JSON:", res.json())

token = res.json().get("data", {}).get("access_token")
print("Token:", token)
print("settings.SECRET_KEY:", settings.SECRET_KEY)
try:
    decoded = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
    print("Decoded locally with settings.SECRET_KEY:", decoded)
except Exception as e:
    print("Failed to decode with settings.SECRET_KEY:", e)
    # Check headers of token unverified
    unverified = jwt.decode(token, options={"verify_signature": False})
    print("Unverified payload:", unverified)
