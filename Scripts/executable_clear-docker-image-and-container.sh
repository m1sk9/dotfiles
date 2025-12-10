#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Clear Docker Image and Container
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🐳

# Documentation:
# @raycast.author m1sk9
# @raycast.authorURL https://m1sk9.dev

# Remove all containers
if [ -n "$(docker ps -aq)" ]; then
  docker rm -f $(docker ps -aq)
  echo "All containers have been removed."
else
  echo "No containers to remove."
fi

# Remove all images
if [ -n "$(docker images -q)" ]; then
  docker rmi -f $(docker images -q)
  echo "All images have been removed."
else
  echo "No images to remove."
fi
