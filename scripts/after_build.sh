#!/bin/bash

echo "export USERNAME=postgres" >> /home/ubuntu/.profile
echo "export PASSWORD=password" >> /home/ubuntu/.profile
echo "export DB_IP=slapp-data-dev.cbw3mio5zyeu.us-east-2.rds.amazonaws.com" >> /home/ubuntu/.profile

source /home/ubuntu/.profile

rm -rf ~/.rbenv

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
source ~/.bashrc
~/.rbenv/bin/rbenv init
eval "$(rbenv init - bash)"

mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build


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

