@echo off
echo Setting environment variables...
set SECRET_KEY=super_secret_jwt_key_for_development_change_in_production_12345
set GOOGLE_API_KEY=AIzaSyCIk5gH-tDX2ygGeNlCAykpVGDtzrngCRY
set DATABASE_URL=sqlite:///./lectures.db
set ACCESS_TOKEN_EXPIRE_MINUTES=30
set WHISPER_MODEL_SIZE=base
set TEMP_FILE_DIR=./temp_uploads
set MAX_FILE_SIZE_MB=500
set MAX_DURATION_MINUTES=120
set BACKGROUND_TASK_TIMEOUT=3600
set CLEANUP_INTERVAL_HOURS=24

echo Starting server...
python main.py