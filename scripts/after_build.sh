#!/bin/bash

sudo apt-get install make gcc libpq-dev build-essential g++

npm install --global yarn

cd /var/www/slapp_data

sudo chown -R ubuntu:ubuntu .

EDITOR="vim --wait" rails credentials:edit

gem install bundler -N

yarn add bootstrap jquery popper.js

bundle install

RAILS_ENV=staging rails assets:precompile

