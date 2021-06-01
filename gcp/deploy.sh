#!/bin/bash

project_id=

code_server_image=gcr.io/$project_id/philfish/code-server

docker pull philfish/code-server

docker tag philfish/code-server $code_server_image

docker push $code_server_image

gcloud run deploy --image=$code_server_image \
    --port=8080 \
    --region=us-central1 \
    --allow-unauthenticated \
    --platform=managed