#!/bin/bash


cd /var/www/slapp_data

sudo chown -R ubuntu:ubuntu .

sudo apt-get install make gcc libpq-dev build-essential g++
sudo apt install nodejs npm

npm install --global yarn



yarn add bootstrap jquery popper.js

EDITOR="vim --wait" rails credentials:edit

gem install bundler -N


bundle install

RAILS_ENV=staging rails assets:precompile

