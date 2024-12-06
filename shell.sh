#!/bin/bash

# Variables
REPO_URL="https://github.com/sovity/sovity-daps.git"
CLONE_DIR="sovity-daps"
AWS_REGION="eu-central-1" 
ECR_REPOSITORY="daps"
IMAGE_TAG="latest"
AWS_ACCOUNT_ID="559050212190"

# Step 1: Clone the repository
echo "Cloning the repository..."
git clone $REPO_URL
cd $CLONE_DIR || exit 1

# Step 3: Authenticate with AWS ECR
echo "Authenticating with AWS ECR..."
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 559050212190.dkr.ecr.eu-central-1.amazonaws.com

# Step 4: Build the Docker image
echo "Building the Docker image..."
docker build -f Dockerfile -t "${ECR_REPOSITORY}:${IMAGE_TAG}" .

# Step 5: Push the Docker image to ECR
echo "Pushing the Docker image to ECR..."
docker tag "${ECR_REPOSITORY}:${IMAGE_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"
docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"

# Done
echo "Docker image has been built and pushed to ECR successfully!"
