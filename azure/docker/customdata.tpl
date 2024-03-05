#!/bin/bash
#Update your local package
sudo apt update -y
#Let apt use packages over HTTPS
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
#Add the GPG key for the official Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#Add the Docker repository to APT sources
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
#Make sure you are about to install from the Docker repo instead of the default Ubuntu repo
apt-cache policy docker-ce
#Install Docker
sudo apt install docker-ce -y
#Add your username to the docker group
sudo usermod -aG docker azureadmin

