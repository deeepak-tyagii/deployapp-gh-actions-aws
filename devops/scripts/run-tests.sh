#!/bin/bash

set -uo pipefail

# Variables
AWS_ACCOUNT_ID="${1:?AWS_ACCOUNT_ID is required}"
REGION="${2:?REGION is required}"
ECR_REPO_NAME="${3:?ECR_REPO_NAME is required}"
IMAGE_TAG="${4:-latest}"

APP_PORT=3000
CONTAINER_NAME="weather-test"
TEST_EXIT_CODE=0 # Default to 0 (success)

# --- Functions ---
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

cleanup() {
  log "Cleaning up docker container..."
  if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
    docker stop "$CONTAINER_NAME" && docker rm "$CONTAINER_NAME"
    log "Container $CONTAINER_NAME stopped and removed."
  else
    log "No container named $CONTAINER_NAME found."
  fi
}

# --- Main Script ---
log "Starting test script..."

# Ensure cleanup runs on script exit, regardless of success or failure
trap cleanup EXIT

log "Logging in to Amazon ECR..."
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

REPOSITORY_URI="$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO_NAME"
log "Repository URI: $REPOSITORY_URI"

log "Pulling Docker image..."
docker pull "$REPOSITORY_URI:$IMAGE_TAG"

# Stop/remove any previous container instance before starting a new one
cleanup 

log "Starting container $CONTAINER_NAME on port $APP_PORT..."
docker run -d -p "$APP_PORT:3000" -e OPENWEATHER_API_KEY -e PORT --name "$CONTAINER_NAME" "$REPOSITORY_URI:$IMAGE_TAG"

log "Waiting for app to start..."
sleep 10
curl --fail http://localhost:3000/health || { log "ERROR: Health check failed."; exit 1; }

log "Installing Cypress and reporters..."
npm install --save-dev

log "Running Cypress tests..."
# Run tests but prevent script from exiting on failure, store the exit code instead.
npm run test || TEST_EXIT_CODE=$?
echo $TEST_EXIT_CODE > test-exit-code.txt

log "Generating test report..."
npm run report

exit 0