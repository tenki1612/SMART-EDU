@echo off
echo ===================================================
echo   Starting FastAPI Backend Server (Language Center)
echo   API Docs: http://localhost:8000/docs
echo ===================================================
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
pause

