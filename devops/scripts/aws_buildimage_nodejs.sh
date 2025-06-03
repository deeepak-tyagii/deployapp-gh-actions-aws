#!/bin/bash

# This script builds a Node image using the centralized Node base image.

DATE=`date +%Y%m%d_%H%M%S`
SCRIPT_NAME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

log_message() {
    local loglevel=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$timestamp [$loglevel] $message"
}

log_message "INFO" "Script ${SCRIPT_NAME}, Started from ${SCRIPT_PATH}"
log_message "INFO" "Assigning Variables"
BASE_ORG_LINUX_NODE_REPOSITORY_NAME=$1
LOCAL_DOCKER_REPOSITORY_NAME=$2
AWS_REGION=$3
base_repo_account=$4
base_image_name="${base_repo_account}/${BASE_ORG_LINUX_NODE_REPOSITORY_NAME}:latest"

for var in BASE_ORG_LINUX_NODE_REPOSITORY_NAME LOCAL_DOCKER_REPOSITORY_NAME AWS_REGION; do
    [[ -z "${!var}" ]] && {
        log_message "ERROR" "Required variable '$var' is empty."
        exit 1
    }
done

log_message "INFO" "========================================================================================"
log_message "INFO" "Getting Variables"
log_message "INFO" "Source Image Name is ${base_image_name}"
log_message "INFO" "Destination Repo Name is ${LOCAL_DOCKER_REPOSITORY_NAME}"
log_message "INFO" "Source Repo Name is ${BASE_ORG_LINUX_NODE_REPOSITORY_NAME}"
log_message "INFO" "AWS Region is ${AWS_REGION}"

log_message "INFO" "========================================================================================"
log_message "INFO" "Logging to ECR ${base_repo_account}"
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $base_repo_account

log_message "INFO" "========================================================================================"
log_message "INFO" "Checking for Base Image ${base_repo_account}"
if docker image inspect "$base_image_name" &> /dev/null; then
    log_message "INFO" "Image $base_image_name found locally. Removing..."
    docker rmi "$base_image_name"
    if [ $? -eq 0 ]; then
        log_message "INFO" "Image $base_image_name removed successfully."
    else
        log_message "ERROR" "Failed to remove image $base_image_name. Exiting."
        exit 1
    fi
fi
docker pull "$base_image_name"
if [ $? -eq 0 ]; then
    log_message "INFO" "Image $base_image_name pulled successfully."
else
    log_message "ERROR" "Failed to pull image $base_image_name. Exiting."
    exit 1
fi

log_message "INFO" "========================================================================================"
log_message "INFO" "Building Docker Image"
docker build -t ${LOCAL_DOCKER_REPOSITORY_NAME} .

log_message "INFO" "========================================================================================"
log_message "INFO" "Checking build app image ${LOCAL_DOCKER_REPOSITORY_NAME} locally."
if docker image inspect "${LOCAL_DOCKER_REPOSITORY_NAME}" &> /dev/null; then
   log_message "INFO" "Image ${LOCAL_DOCKER_REPOSITORY_NAME} found locally."
else
    log_message "ERROR" "Failed to create image ${LOCAL_DOCKER_REPOSITORY_NAME}. Exiting."
    exit 1
fi

log_message "INFO" "========================================================================================"
log_message "INFO" "Listing Images on Agent"
docker images -a