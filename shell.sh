#!/bin/bash

# Variables
REPO_URL="https://github.com/sovity/sovity-daps.git"
CLONE_DIR="sovity-daps"
AWS_REGION="eu-central-1" 
ECR_REPOSITORY="daps"
IMAGE_TAG="latest"
AWS_ACCOUNT_ID="559050212190"
DOCKERFILE_CONTENT="""
ARG KC_VERSION=24.0.3

FROM maven:3-eclipse-temurin-17 AS daps-ext-builder
ARG KC_VERSION

WORKDIR /home/app
COPY . ./
#RUN --mount=type=cache,target=/root/.m2 mvn -D \"version.keycloak=${KC_VERSION}\" clean package
RUN mvn -D \"version.keycloak=${KC_VERSION}\" clean package

FROM quay.io/keycloak/keycloak:${KC_VERSION}
COPY --from=daps-ext-builder /home/app/target/dat-extension.jar /opt/keycloak/providers/dat-extension.jar

# Theme Customization
COPY themes/ /opt/keycloak/themes/

CMD [\"start\"]
"""

# Step 1: Clone the repository
echo "Cloning the repository..."
git clone $REPO_URL
cd $CLONE_DIR || exit 1

# Step 2: Replace Dockerfile with the provided one
echo "Replacing Dockerfile..."
echo "$DOCKERFILE_CONTENT" > Dockerfile

# Step 3: Authenticate with AWS ECR
echo "Authenticating with AWS ECR..."
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 559050212190.dkr.ecr.eu-central-1.amazonaws.com

# Step 4: Build the Docker image
echo "Building the Docker image..."
docker build -t "${ECR_REPOSITORY}:${IMAGE_TAG}" .

# Step 5: Push the Docker image to ECR
echo "Pushing the Docker image to ECR..."
docker tag "${ECR_REPOSITORY}:${IMAGE_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"
docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"

# Done
echo "Docker image has been built and pushed to ECR successfully!"
