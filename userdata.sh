#!/bin/bash
sudo apt update -y
sudo apt install nginx -y 
sudo systemctl enable nginx
echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.nginx-debian.html
sudo systemctl start nginx