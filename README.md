## Introduction
- Web applications framework: Shiny, using R lang
- The APP builds up as a Docker image
- Upload the docker image to Google Cloud Platform (GCP), and the docker container is running by Cloud Run.
- Recommended Cloud Run Container: 2 CPU, 8G ram



## Pre-installation
- Install docker
- Install the [gcloud CLI](!https://cloud.google.com/sdk/docs/install)
- Create a Google Cloud project, get the `PROJECT ID`




## Deployment
``` shell
# build image
docker build -t apu:latest .

# switch account to your gcp google account
gcloud config set account {YOUR_GOOGLE_ACCOUNT}

# set project 
gcloud config set project {YOUR_GCP_PROJECT_ID} && PROJECTID=$(gcloud config get-value project)

# ultilize Googld Builds to build image
docker build . -t gcr.io/$PROJECTID/apu

# test locally
# docker run --rm -p 9999:80 --name apu apu:latest
# see http://localhost:9999/

# push to gcp
docker push gcr.io/$PROJECTID/apu

# deploy on gcp cloud run
gcloud run deploy --image gcr.io/$PROJECTID/apu --port=80 --platform managed --region asia-east1 --cpu 2 --memory 8Gi

```
