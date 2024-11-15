#! /bin/bash

docker_host="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
curl -o src/aembit_root.crt "https://${AEMBIT_TENANT_ID}.aembit.io/api/v1/root-ca"

(cd src && docker build --platform linux/amd64 --provenance=false -t "${IMAGE_NAME}" .)

aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${docker_host}"
docker tag "${IMAGE_NAME}:latest" "${docker_host}/${IMAGE_NAME}:latest"
docker push "${docker_host}/${IMAGE_NAME}:latest"

rm src/aembit_root.crt
