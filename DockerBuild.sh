#!/bin/bash

# Set the project root
PROJECT_ROOT=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)")

# Initialize variables to default values
BUILD_U="NO"
BUILD_D="NO"
BUILD_S="NO"
BUILD_I="NO"
CLEAN="NO"
NO_CACHE="NO"

# Function to display usage
usage() {
  echo "Usage: $0 [-c] [-u] [-d] [-s] [-i] [-n]"
  exit 1
}

# Parse command line arguments
while getopts "cudsin" opt; do
  case $opt in
    c) CLEAN="YES" ;;
    u) BUILD_U="YES" ;;
    d) BUILD_D="YES" ;;
    s) BUILD_S="YES" ;;
    i) BUILD_I="YES" ;;
    n) NO_CACHE="--no-cache" ;;
    \?) usage ;; # Invalid option
  esac
done

# Debug: Print out the values to ensure they're set correctly
echo "CLEAN=$CLEAN, BUILD_U=$BUILD_U, BUILD_D=$BUILD_D, BUILD_S=$BUILD_S, BUILD_I=$BUILD_I, NO_CACHE=$NO_CACHE"

# Build Docker image with the appropriate arguments
docker build $NO_CACHE -t orcaslicer \
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
