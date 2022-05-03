#!/bin/bash

bash resize.sh 40

sudo growpart /dev/nvme0n1 1

echo "export USERNAME=postgres" >> /home/ubuntu/.profile
echo "export PASSWORD=password" >> /home/ubuntu/.profile
echo "export DB_IP=slapp-data-dev.cbw3mio5zyeu.us-east-2.rds.amazonaws.com" >> /home/ubuntu/.profile

source /home/ubuntu/.profile

rvm install 3.0.0

gem update bundler

sudo apt install -y libpq-dev

bundle install

