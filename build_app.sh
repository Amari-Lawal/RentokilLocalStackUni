#!/usr/bin/env bash

set -e

MODE="$1"

if [[ -z "$MODE" ]]; then
  echo "Usage: ./build_app.sh --local | --test"
  exit 1
fi

case "$MODE" in
  --local)
    echo "🔧 Building UNIFIED LOCAL environment (Frontend, Backend)..."
    docker compose down
    kill -9 $(lsof -t -i:8080) 2>/dev/null || true
    kill -9 $(lsof -t -i:5173) 2>/dev/null || true
    docker compose up --build
    ;;
  --test)
    echo "🔧 Running Backend Unit Tests..."
    # Delegate backend tests to the backend's specific docker-compose
    cd ../RentokilSelfServiceBackendUni
    docker compose -f docker-compose.local.yml build test
    docker compose -f docker-compose.local.yml run --rm test
    cd ../rentokil-local-stack
    
    cleanup() {
        echo "🔧 Tearing down Unified Stack..."
        docker compose down
    }
    trap cleanup EXIT

    echo "🔧 Starting Unified Stack for Frontend E2E Tests..."
    docker compose down
    kill -9 $(lsof -t -i:8080) 2>/dev/null || true
    kill -9 $(lsof -t -i:5173) 2>/dev/null || true
    docker compose up -d --build
    
    # Wait for the backend to be responsive
    echo "Waiting for backend API..."
    until curl -s http://localhost:8080/health > /dev/null; do
        sleep 2
    done
    
    echo "Waiting for frontend server..."
    until curl -s http://localhost:5173 > /dev/null; do
        sleep 2
    done
    
    echo "🔧 Running Frontend E2E Tests..."
    cd ../RentokilSelfServiceFrontendUni
    # Ensure dependencies are installed for playwright
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing frontend dependencies..."
        npm install
    fi
    npx playwright test e2e/workflow.spec.js
    cd ../rentokil-local-stack
    ;;
  *)
    echo "❌ Unknown option: $MODE"
    echo "Use --local or --test"
    exit 1
    ;;
esac
