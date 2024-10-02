#!/bin/bash

# Set the project ID from the gcloud config or use a default value
PROJECT_ID="${PROJECT_ID:-$(gcloud config get-value project)}"
# Set the location for the Artifact Registry repository
LOCATION="us"
# Set the name for the Artifact Registry repository
REPOSITORY="cooking-images"
# Construct the full repository URI
FULL_REPO="${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}"
# Set the name for the Docker image
IMAGE_NAME="recipe-web-app"

# Check if the Artifact Registry repository already exists
if ! gcloud artifacts repositories describe "${REPOSITORY}" --location="${LOCATION}" --project="${PROJECT_ID}" &>/dev/null; then
    # If the repository doesn't exist, create it
    echo "Repository '$REPOSITORY' does not exist. Creating..."

    gcloud artifacts repositories create "${REPOSITORY}" \
        --repository-format=docker \
        --location="${LOCATION}" \
        --project="${PROJECT_ID}"
    echo "Repository '$FULL_REPO' created successfully."
else
    # If the repository exists, log a message
    echo "Repository '$FULL_REPO' already exists."
fi

# Build the Docker image and push it to the Artifact Registry repository
gcloud builds submit --tag $FULL_REPO/$IMAGE_NAME:latest .

# Deploy the Docker image to Cloud Run
gcloud run deploy $IMAGE_NAME \
    --platform=managed \
    --allow-unauthenticated \
    --image=$FULL_REPO/$IMAGE_NAME:latest --region=us-central1 --port=8501