#!/bin/bash

sudo apt-get install make gcc libpq-dev build-essential g++

cd /var/www/slapp_data

sudo chown -R ubuntu:ubuntu .

EDITOR="vim --wait" rails credentials:edit

sudo gem install bundler -N

sudo bundle install

