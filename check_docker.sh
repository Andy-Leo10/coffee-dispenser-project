#!/bin/bash

sudo pkill -f gzserver
sudo pkill -f gzclient

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Installing now..."
    # Check if apt-get is currently in use
    if ps aux | grep -i apt | grep -v grep
    then
        echo "apt-get is currently in use. Please wait for the other process to finish before running this script again."
    else
        sudo apt-get update
        sudo apt-get install docker.io docker-compose -y
        sudo service docker start
        sudo chmod 666 /var/run/docker.sock
    fi
else
    echo "Docker is already installed."
    sudo chmod 666 /var/run/docker.sock
fi

sudo apt-get update
sudo apt-get install x11-xserver-utils