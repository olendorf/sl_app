#!/bin/bash

# bash scripts/resize.sh 40

# sudo growpart /dev/nvme0n1 1

# echo "export USERNAME=postgres" >> /home/ubuntu/.profile
# echo "export PASSWORD=password" >> /home/ubuntu/.profile
# echo "export DB_IP=slapp-data-dev.cbw3mio5zyeu.us-east-2.rds.amazonaws.com" >> /home/ubuntu/.profile

# source /home/ubuntu/.profile

# rvm get stable

# rvm install 3.0.0

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then

  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"

elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then

  # Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"

else

  printf "ERROR: An RVM installation was not found.\n"

fi

rvm --default use 3.0.0

gem update bundler

sudo apt install -y libpq-dev

bundle install

