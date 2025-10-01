#!/bin/bash

# Production Startup Script for Lecture to Slides

set -e

echo "🚀 Starting Lecture to Slides in Production Mode"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if environment files exist
if [ ! -f "backend/.env" ]; then
    echo "❌ Backend .env file not found. Please copy backend/production.env.example to backend/.env and configure it."
    exit 1
fi

if [ ! -f "frontend/.env.production" ]; then
    echo "⚠️  Frontend .env.production file not found. Using defaults."
fi

# Create necessary directories
mkdir -p backend/temp_uploads
mkdir -p backend/exports
mkdir -p ssl

echo "📦 Building and starting services..."

# Build and start services
docker-compose up --build -d

echo "⏳ Waiting for services to be healthy..."

# Wait for services to be ready
timeout=300
counter=0

while [ $counter -lt $timeout ]; do
    if docker-compose ps | grep -q "Up (healthy)"; then
        echo "✅ Services are healthy!"
        break
    fi
    
    echo "⏳ Waiting for services... ($counter/$timeout seconds)"
    sleep 5
    counter=$((counter + 5))
done

if [ $counter -ge $timeout ]; then
    echo "❌ Services failed to start within $timeout seconds"
    echo "📋 Service status:"
    docker-compose ps
    echo "📋 Logs:"
    docker-compose logs --tail=50
    exit 1
fi

echo "🎉 Lecture to Slides is now running!"
echo ""
echo "📍 Frontend: http://localhost:3000"
echo "📍 Backend API: http://localhost:8000"
echo "📍 Health Check: http://localhost/health"
echo ""
echo "📋 To view logs: docker-compose logs -f"
echo "🛑 To stop: docker-compose down"
echo "🔄 To restart: docker-compose restart"