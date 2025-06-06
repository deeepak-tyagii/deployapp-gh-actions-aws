#!/bin/bash

set -euo pipefail

# Variables from input parameters
AWS_ACCOUNT_ID="${1:?AWS_ACCOUNT_ID is required}"
REGION="${2:?REGION is required}"
ECR_REPO_NAME="${3:?ECR_REPO_NAME is required}"
IMAGE_TAG="${4:-latest}"  # default to latest if not provided

APP_PORT=3000
CYPRESS_BASE_URL="http://localhost:$APP_PORT"
CONTAINER_NAME="weather-test"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

cleanup() {
  log "Cleaning up docker container if exists..."
  if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
    docker stop "$CONTAINER_NAME" && docker rm "$CONTAINER_NAME"
    log "Container $CONTAINER_NAME stopped and removed."
  else
    log "No container named $CONTAINER_NAME found."
  fi
}

error_exit() {
  local exit_code=$1
  local msg="${2:-Script failed with exit code $exit_code}"
  log "ERROR: $msg"
  cleanup
  exit "$exit_code"
}

trap 'error_exit $? "An unexpected error occurred."' ERR INT TERM

log "Starting test script..."

log "Logging in to Amazon ECR..."
aws --version

aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

REPOSITORY_URI="$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO_NAME"
log "Repository URI: $REPOSITORY_URI"

log "Pulling Docker image $REPOSITORY_URI:$IMAGE_TAG..."
docker pull "$REPOSITORY_URI:$IMAGE_TAG"

cleanup

log "Starting container $CONTAINER_NAME on port $APP_PORT..."

docker run -d -p  "$APP_PORT:3000" -e OPENWEATHER_API_KEY -e PORT --name "$CONTAINER_NAME" "$REPOSITORY_URI:$IMAGE_TAG"

log "Waiting for app to start..."
sleep 10
curl http://localhost:3000/health || error_exit $? "Health check failed."

log "Installing Cypress and reporters..."
npm install --save-dev

log "Running Cypress tests..."
npm run test

log "generating test report..."
npm run report

log "Tests completed. Cleaning up container..."
cleanup

if [[ "${TEST_EXIT_CODE:-0}" -ne 0 ]]; then
  error_exit "$TEST_EXIT_CODE" "Cypress tests failed."
fi

log "Test script finished successfully."
exit 0
