#!/bin/bash
#Update your local package
sudo apt update -y
#Install NGNIX 
sudo apt install nginx -y
#Update Firewall
sudo ufw allow 'Nginx Full'