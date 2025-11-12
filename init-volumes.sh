#!/bin/bash
echo "📦 Initializing volumes with code..."

# Remove existing volumes if they exist
docker volume rm repo_backend_code repo_frontend_code 2>/dev/null || true

# Create temporary containers to copy code to volumes
echo "Copying backend code to volume..."
docker container create --name temp_backend -v repo_backend_code:/app busybox
docker cp ./backend/. temp_backend:/app/
docker rm temp_backend

echo "Copying frontend code to volume..."
docker container create --name temp_frontend -v repo_frontend_code:/app busybox
docker cp ./frontend/. temp_frontend:/app/
docker rm temp_frontend

echo "✅ Volume initialization complete"
