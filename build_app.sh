#!/usr/bin/env bash

set -e

MODE="$1"

if [[ -z "$MODE" ]]; then
  echo "Usage: ./build_app.sh --local | --test | --pentest | --test-staging"
  exit 1
fi

case "$MODE" in
  --local)
    echo "Building UNIFIED LOCAL environment (Frontend, Backend)..."
    docker compose down
    kill -9 $(lsof -t -i:8080) 2>/dev/null || true
    kill -9 $(lsof -t -i:5173) 2>/dev/null || true
    docker compose up --build
    ;;
  --test)
    echo "Running Backend Unit Tests..."
    # Delegate backend tests to the backend's specific docker-compose
    cd ../RentokilSelfServiceBackendUni
    docker compose -f docker-compose.local.yml build test
    docker compose -f docker-compose.local.yml run --rm test
    cd ../RentokilLocalStackUni
    
    cleanup() {
        echo "Tearing down Unified Stack..."
        docker compose down
    }
    trap cleanup EXIT

    echo "Starting Unified Stack for Frontend E2E Tests..."
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
    
    echo "Running Frontend E2E Tests..."
    cd ../RentokilSelfServiceFrontendUni
    # Ensure dependencies are installed for playwright
    if [ ! -d "node_modules" ]; then
        echo "Installing frontend dependencies..."
        npm install
    fi
    npx playwright test e2e/workflow.spec.js
    cd ../RentokilLocalStackUni
    ;;
  --test-staging)
    echo "Running Backend Unit Tests..."
    # Delegate backend tests to the backend's specific docker-compose
    cd ../RentokilSelfServiceBackendUni
    docker compose -f docker-compose.local.yml build test
    docker compose -f docker-compose.local.yml run --rm test
    cd ../RentokilLocalStackUni

    echo "Running Frontend E2E Tests against Live URL: $PLAYWRIGHT_TEST_BASE_URL"
    if [[ -z "$PLAYWRIGHT_TEST_BASE_URL" ]]; then
      echo "ERROR: PLAYWRIGHT_TEST_BASE_URL environment variable is not set."
      exit 1
    fi
    cd ../RentokilSelfServiceFrontendUni
    # Ensure dependencies are installed for playwright
    if [ ! -d "node_modules" ]; then
        echo "Installing frontend dependencies..."
        npm install
    fi
    npx playwright test e2e/workflow.spec.js
    cd ../RentokilLocalStackUni
    ;;
  --pentest)
    echo "Running Security Penetration Tests (OWASP Top 10)..."
    
    cleanup_pentest() {
        echo "Tearing down Unified Stack..."
        docker compose down
    }
    trap cleanup_pentest EXIT

    echo "Starting Unified Stack for Security Auditing..."
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
    
    echo "Running Playwright Penetration Tests..."
    cd ../RentokilSelfServiceFrontendUni
    if [ ! -d "node_modules" ]; then
        echo "Installing frontend dependencies..."
        npm install
    fi
    
    # Run the specific pentest suite
    npx playwright test e2e/pentest.spec.js
    
    echo ""
    echo "Pentest Complete!"
    echo "Videos: RentokilSelfServiceFrontendUni/Pentest/videos/"
    echo "Screenshots: RentokilSelfServiceFrontendUni/Pentest/screenshots/"
    echo "HTML Report: npx playwright show-report"
    
    cd ../RentokilLocalStackUni
    ;;
  *)
    echo "ERROR: Unknown option: $MODE"
    echo "Use --local, --test, --pentest, or --test-staging"
    exit 1
    ;;
esac
