echo "export USERNAME=postgres" >> ~/.profile 
echo "export PASSWORD=password" >> ~/.profile
echo "export DB_IP=slapp-data-dev.cbw3mio5zyeu.us-east-2.rds.amazonaws.com" >> ~/.profile 
source ~/.profile 
sudo apt install libpq-dev
gem install bundler
bundle install
npm install --global yarn
EDITOR="vim --wait" rails credentials:edit