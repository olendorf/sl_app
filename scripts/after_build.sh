#!/bin/bash

# rm -rf ~/.rbenv



sudo chown -R ubuntu:ubuntu /var/www/slapp_data
sudo apt update -y

sudo apt install -y git wget curl autoconf bison build-essential \
    libssl-dev libyaml-dev libreadline6-dev zlib1g-dev \
    libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev g++

sudo apt -y install nodejs npm libreadline-dev zlib1g-dev
sudo npm install -g n
sudo n 12.0.0

sudo npm install --global yarn

# curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

sudo apt-get -y install rbenv ruby-build

# echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
# echo 'eval "$(rbenv init -)"' >> ~/.bashrc
# source /home/ubuntu/.bashrc

rbenv install 2.6.3
rbenv global 2.6.3


exec bash


gem install bundler -N



bundle install


# EDITOR="vim --wait" rails credentials:edit

# RAILS_ENV=staging rails assets:precompile

