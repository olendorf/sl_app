#!/bin/bash


cd /var/www/slapp_data

sudo chown -R ubuntu:ubuntu .
sudo apt-get update -y
sudo apt-get -y install make gcc libpq-dev build-essential g++
sudo apt -y install nodejs npm
sudo npm install -g n
sudo n 12.0.0

sudo npm install --global yarn



yarn add bootstrap jquery popper.js

EDITOR="vim --wait" rails credentials:edit


gem install bundler -N


bundle install

RAILS_ENV=staging rails assets:precompile

