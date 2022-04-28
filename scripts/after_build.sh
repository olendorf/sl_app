#!/bin/bash


cd /var/www/slapp_data

sudo chown -R ubuntu:ubuntu .
sudo apt-get update -y
sudo apt-get -y libpq-dev build-essential g++
sudo apt -y install nodejs npm
sudo npm install -g n
sudo n 12.0.0

sudo npm install --global yarn



yarn add bootstrap jquery @popperjs/core

whoami
pwd
ls -al 

echo 'export GEM_HOME=~/.ruby/' >> ~/.bashrc
echo 'export PATH="$PATH:~/.ruby/bin"' >> ~/.bashrc
source ~/.bashrc

gem install bundler -N



bundle install


EDITOR="vim --wait" rails credentials:edit

RAILS_ENV=staging rails assets:precompile

