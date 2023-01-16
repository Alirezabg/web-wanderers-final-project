sudo apt update
sudo apt install --yes docker-ce
sudo usermod -a -G docker ${USER}
gcloud auth configure-docker us-central1-docker.pkg.dev
docker pull \
    us-central1-docker.pkg.dev/planar-elevator-374616/quickstart-docker-repo/quickstart-image@sha256:5c399fa1c83c3103a33338ffeb16bf16530c3902241b82b44e75b9119e65a586
sudo docker pull us-central1-docker.pkg.dev/planar-elevator-374616/quickstart-docker-repo/quickstart-image:tag1
docker tag $(docker images "us-central1-docker.pkg.dev/planar-elevator-374616/quickstart-docker-repo/quickstart-image" -q) api:v1
sudo docker run -p 4000:4000 api:v1