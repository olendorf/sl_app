#!/bin/bash

rm -rf ~/.rbenv


sudo chown -R ubuntu:ubuntu /var/www/slapp_data
sudo apt-get update -y

sudo apt-get -y libpq-dev build-essential g++
sudo apt -y install nodejs npm libreadline-dev zlib1g-dev
sudo npm install -g n
sudo n 12.0.0

sudo npm install --global yarn



git clone https://github.com/rbenv/rbenv.git ~/.rbenv
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
$ echo 'eval "$(rbenv init -)"' >> ~/.bashrc
$ exec $SHELL

mkdir -p /home/ubuntu/.rbenv/plugins
git clone https://github.com/rbenv/ruby-build.git /home/ubuntu/.rbenv/plugins/ruby-build

rbenv install 2.6.3
rbenv global 2.6.3


# cd /var/www/slapp_data

# sudo chown -R ubuntu:ubuntu .
# sudo apt-get update -y
# sudo apt-get -y libpq-dev build-essential g++
# sudo apt -y install nodejs npm
# sudo npm install -g n
# sudo n 12.0.0

# sudo npm install --global yarn



# yarn add bootstrap jquery @popperjs/core

# sudo apt purge -y ruby

# sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev

# git clone https://github.com/rbenv/rbenv.git ~/.rbenv
# echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
# echo 'eval "$(rbenv init -)"' >> ~/.bashrc
# exec $SHELL

# git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
# echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
# exec $SHELL

# rbenv install 2.3.1
# rbenv global 2.3.1
# ruby -v

# gem install bundler -N



# bundle install


# EDITOR="vim --wait" rails credentials:edit

# RAILS_ENV=staging rails assets:precompile

