#!/bin/bash

# Default project name to 'orcaslicer' if not provided
PROJECT_NAME=${1:-orcaslicer}

set -x

# Stop and remove containers related to the project
docker stop $(docker ps -q --filter "ancestor=$PROJECT_NAME") 2>/dev/null
docker rm $(docker ps -a -q --filter "ancestor=$PROJECT_NAME") 2>/dev/null

# Ensure all containers using the volumes are removed
CONTAINERS_USING_VOLUMES=$(docker ps -a -q --filter "volume=${PROJECT_NAME}_build_cache" --filter "volume=${PROJECT_NAME}_deps_cache")
if [ -n "$CONTAINERS_USING_VOLUMES" ]; then
    echo "Removing containers using the volumes: $CONTAINERS_USING_VOLUMES"
    docker rm -f $CONTAINERS_USING_VOLUMES
fi

# Remove images related to the project
docker rmi $(docker images -q $PROJECT_NAME) 2>/dev/null
docker rmi $(docker images -q ${PROJECT_NAME}_${PROJECT_NAME}) 2>/dev/null

# Remove volumes related to the project
docker volume rm $(docker volume ls -q --filter "name=${PROJECT_NAME}_build_cache") 2>/dev/null
docker volume rm $(docker volume ls -q --filter "name=${PROJECT_NAME}_deps_cache") 2>/dev/null

# Double-check and force remove any remaining volumes
REMAINING_VOLUMES=$(docker volume ls -q --filter "name=$PROJECT_NAME")
if [ -n "$REMAINING_VOLUMES" ]; then
    echo "Force removing volumes: $REMAINING_VOLUMES"
    docker volume rm --force $REMAINING_VOLUMES
fi

# Remove networks related to the project
docker network rm $(docker network ls -q --filter "name=$PROJECT_NAME") 2>/dev/null

# Prune build cache related to the project
docker builder prune -f --filter "label=$PROJECT_NAME"




