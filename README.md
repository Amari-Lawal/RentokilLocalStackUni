# Rentokil Unified Local Stack

This repository provides a unified local environment for developing and testing the Rentokil Self-Service application, including both the Frontend and Backend services.

## Prerequisites

- **Docker & Docker Compose**: To run the containerized services.
- **Node.js & npm**: Required on the host machine if you want to run the Playwright E2E tests via the build script.

## Getting Started

The project uses a unified build script to manage the lifecycle of the local environment.

### 1. Run Everything Locally
To build and start both the Frontend (Vite) and Backend (FastAPI) in development mode:
```bash
./build_app.sh --local
```
- **Frontend**: Accessible at [http://localhost:5173](http://localhost:5173)
- **Backend API**: Accessible at [http://localhost:8080](http://localhost:8080)
- **API Docs**: [http://localhost:8080/docs](http://localhost:8080/docs)

### 2. Run All Tests
To run the full test suite (Backend Unit Tests + Frontend E2E Tests):
```bash
./build_app.sh --test
```
This script will:
1. Run Backend Pytest units in a temporary container.
2. Spin up a full environment (Frontend + Backend).
3. Wait for services to be ready.
4. Execute Playwright E2E tests on your host machine.
5. Automatically tear down the environment after completion.

## Project Structure

- `../RentokilSelfServiceBackendUni`: FastAPI Backend logic.
- `../RentokilSelfServiceFrontendUni`: React + Vite Frontend logic.
- `docker-compose.yml`: Defines the interaction between services and environment injection.
- `build_app.sh`: Automated workflow script for local dev and testing.

## Environment Variables
The local stack injects a development secret `RentokilLocalSecretKey2026` for JWT authentication. For production, these are managed via GitHub Actions secrets.


# Google Cloud Production URLs
## Dev
- https://rentokil-frontend-uni-dev-662756251108.europe-west1.run.app
- https://rentokil-backend-uni-dev-662756251108.europe-west1.run.app

## Test 
- https://rentokil-frontend-uni-test-662756251108.europe-west1.run.app
- https://rentokil-backend-uni-test-662756251108.europe-west1.run.app

## Prod
- https://rentokil-frontend-uni-prod-662756251108.europe-west1.run.app
- https://rentokil-backend-uni-prod-662756251108.europe-west1.run.app


# Backend Repository
https://github.com/Amari-Lawal/RentokilSelfServiceBackendUni

# Frontend Repository
https://github.com/Amari-Lawal/RentokilSelfServiceFrontendUni   