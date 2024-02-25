locals {
  custom_data = <<CUSTOM_DATA
  #!/bin/bash
  #Debian package repository of Jenkins to automate installation and upgrade
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    #Add a Jenkins apt repository entry
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    #Update your local package
    sudo apt-get update
    #Install Java
    sudo apt-get install fontconfig openjdk-11-jre -y
    #Install Jenkins
    sudo apt-get install jenkins -y 
    #Start Jenkins Service
    sudo systemctl start jenkins
    #Enable Jenkins on startup
    sudo systemctl enable jenkins
    #Add firewall entry	
    sudo ufw allow 8080
  CUSTOM_DATA
  }