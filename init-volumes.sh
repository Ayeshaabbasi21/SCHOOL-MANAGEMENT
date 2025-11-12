#!/bin/bash
echo "📦 Setting up application with dependencies..."

# Remove existing volumes
docker volume rm backend_code frontend_code ci_mongo_data 2>/dev/null || true

# Create backend with dependencies
echo "Installing backend dependencies..."
docker run --rm -v $(pwd)/backend:/app -w /app node:18-bullseye \
  sh -c "npm install --silent && cp -r /app/node_modules /tmp/"

# Create frontend with dependencies  
echo "Installing frontend dependencies..."
docker run --rm -v $(pwd)/frontend:/app -w /app node:18-bullseye \
  sh -c "npm install --silent && npm run build && cp -r /app/node_modules /tmp/ && cp -r /app/build /tmp/"

echo "✅ Dependencies installed and ready"
