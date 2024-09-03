#!/bin/bash

# Set the project root
PROJECT_ROOT=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)")

# Initialize variables to default values
BUILD_U="NO"
BUILD_D="NO"
BUILD_S="NO"
BUILD_I="NO"
CLEAN="NO"

# Function to display usage
usage() {
  echo "Usage: $0 [-c] [-u] [-d] [-s] [-i]"
  exit 1
}

# Parse command line arguments
while getopts "cudsi" opt; do
  case $opt in
    c) CLEAN="YES" ;;
    u) BUILD_U="YES" ;;
    d) BUILD_D="YES" ;;
    s) BUILD_S="YES" ;;
    i) BUILD_I="YES" ;;
    \?) usage ;; # Invalid option
  esac
done

# Debug: Print out the values to ensure they're set correctly
echo "CLEAN=$CLEAN, BUILD_U=$BUILD_U, BUILD_D=$BUILD_D, BUILD_S=$BUILD_S, BUILD_I=$BUILD_I"

# Build Docker image with the appropriate arguments
DOCKER_BUILDKIT=0 docker build --no-cache -t orcaslicer \
  --build-arg CLEAN=$CLEAN \
  --build-arg USER=$USER \
  --build-arg UID=$(id -u) \
  --build-arg GID=$(id -g) \
  --build-arg NCORES=$(nproc) \
  --build-arg BUILD_U=$BUILD_U \
  --build-arg BUILD_D=$BUILD_D \
  --build-arg BUILD_S=$BUILD_S \
  --build-arg BUILD_I=$BUILD_I \
  $PROJECT_ROOT 
