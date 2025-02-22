sudo apt update
sudo apt install --yes apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt update
sudo apt install --yes docker-ce
sudo usermod -a -G docker ${USER}
gcloud auth configure-docker us-central1-docker.pkg.dev -q
sudo docker pull \
    us-central1-docker.pkg.dev/planar-elevator-374616/client/client-image@sha256:31513e2ef059ced5884f9564134eb56f632d2889ec1f249179969abbeb200636
sudo docker tag $(docker images "us-central1-docker.pkg.dev/planar-elevator-374616/client/client-image" -q) client:v1
sudo docker run --env REACT_APP_API_PATH = http://10.128.0.5:4000/api/ -d -p 3000:3000 client:v1
