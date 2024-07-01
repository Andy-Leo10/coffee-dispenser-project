#!/bin/bash

# Get the IDs of all running Docker containers
container_ids=$(docker ps -q)

# If there are any running Docker containers, kill them
if [ ! -z "$container_ids" ]; then
    docker kill $container_ids
fi

# Remove all stopped containers
docker container prune -f

# Check X11 display settings
ls -la /tmp/.X11-unix/
echo $DISPLAY

# Remove access control restrictions
xhost +local:root

# Add current user to the docker group
sudo usermod -aG docker $USER