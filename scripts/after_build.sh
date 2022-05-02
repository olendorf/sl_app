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

curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

# sudo apt-get -y install rbenv ruby-build

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source /home/ubuntu/.bashrc

rbenv install 2.6.3
rbenv global 2.6.3


exec bash

# sudo apt install -y apache2

# sudo ufw allow 'Apache Full'
# sudo ufw allow 'OpenSSH'

# sudo apt-get install -y dirmngr gnupg
# sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
# sudo apt-get install -y apt-transport-https ca-certificates

# sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger bionic main > /etc/apt/sources.list.d/passenger.list'
# sudo apt-get -y update

# sudo apt-get install -y libapache2-mod-passenger

# sudo a2enmod passenger
# sudo apache2ctl restart

# gem install bundler -N



# bundle install


# EDITOR="vim --wait" rails credentials:edit

# RAILS_ENV=staging rails assets:precompile

