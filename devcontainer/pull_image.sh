#!/bin/bash

# Path to the devcontainer.json file
DEVCONTAINER_FILE=$1
PLATFORM=$2

# Check if the devcontainer.json file exists
if [ ! -f "$DEVCONTAINER_FILE" ]; then
    echo "Error: $DEVCONTAINER_FILE not found!"
    exit 1
fi

# Extract the image and dockerfile fields from the devcontainer.json file
IMAGE=$(jq -r '.image' "$DEVCONTAINER_FILE")
DOCKERFILE=$(jq -r '.dockerfile' "$DEVCONTAINER_FILE")
CONTEXT=$(jq -r '.context' "$DEVCONTAINER_FILE")

# Function to pull the Docker image
pull_image() {
    echo "Pulling Docker image: $1"
    docker pull "$1" --platform "$2"
    if [ $? -eq 0 ]; then
        echo "Docker image $1 pulled successfully."
    else
        echo "Error: Failed to pull Docker image $1."
        exit 1
    fi
}

# Function to extract and pull the base image from a Dockerfile
pull_base_image_from_dockerfile() {
    BASE_IMAGE=$(grep -i "^FROM" "$1" | head -n 1 | awk '{print $2}')

    if [ -n "$BASE_IMAGE" ]; then
        pull_image "$BASE_IMAGE" "$2"
    else
        echo "Error: No valid base image found in Dockerfile $1."
        exit 1
    fi
}

# Decide whether to pull an image or extract and pull the base image from a Dockerfile
if [ "$IMAGE" != "null" ] && [ -n "$IMAGE" ]; then
    # Case 1: An image is specified
    pull_image "$IMAGE" "$PLATFORM"
elif [ "$DOCKERFILE" != "null" ] && [ -n "$DOCKERFILE" ]; then
    # Case 2: A Dockerfile is referenced
    # Check if context is provided, otherwise use the default context (.)
    if [ "$CONTEXT" == "null" ] || [ -z "$CONTEXT" ]; then
        CONTEXT="."
    fi

    # Check if the Dockerfile exists
    if [ ! -f "$CONTEXT/$DOCKERFILE" ]; then
        echo "Error: Dockerfile $DOCKERFILE not found in context $CONTEXT!"
        exit 1
    fi

    # Pull the base image from the Dockerfile
    pull_base_image_from_dockerfile "$CONTEXT/$DOCKERFILE" "$PLATFORM"
else
    echo "Error: Neither image nor Dockerfile is specified in $DEVCONTAINER_FILE"
    exit 1
fi
