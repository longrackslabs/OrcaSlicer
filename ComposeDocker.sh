#!/bin/bash
PROJECT_ROOT=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)")

# Default build argument values
BUILD_U="NO"
BUILD_D="NO"
BUILD_S="NO"
BUILD_I="NO"

# Parse command-line arguments
while getopts "udsi" opt; do
  case $opt in
    u) BUILD_U="YES" ;;
    d) BUILD_D="YES" ;;
    s) BUILD_S="YES" ;;
    i) BUILD_I="YES" ;;
    *) echo "Invalid option: -$OPTARG" ;;
  esac
done

# Build with Docker, passing in the build arguments
docker build -t orcaslicer \
  --build-arg USER=$USER \
  --build-arg UID=$(id -u) \
  --build-arg GID=$(id -g) \
  --build-arg BUILD_U=$BUILD_U \
  --build-arg BUILD_D=$BUILD_D \
  --build-arg BUILD_S=$BUILD_S \
  --build-arg BUILD_I=$BUILD_I \
  $PROJECT_ROOT
