sudo apt update
sudo apt install --yes docker-ce
sudo usermod -a -G docker ${USER}
gcloud auth configure-docker us-central1-docker.pkg.dev
docker pull \
    us-central1-docker.pkg.dev/planar-elevator-374616/client/client-image@sha256:31513e2ef059ced5884f9564134eb56f632d2889ec1f249179969abbeb200636
sudo docker pull us-central1-docker.pkg.dev/planar-elevator-374616/client/client-image:tag1
docker tag $(docker images "us-central1-docker.pkg.dev/planar-elevator-374616/client/client-image" -q) client:v1
sudo docker run -p 3000:3000 client:v1