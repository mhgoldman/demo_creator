#!/bin/bash

# Install script - Tested on Ubuntu 14.04 ONLY
set -e 

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get -y install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev libgdbm-dev libncurses5-dev automake libtool bison libffi-dev libgmp-dev postgresql libpq-dev nodejs libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
# DON'T PROMPT!

sudo -u postgres createuser `whoami` -s

command curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -L https://get.rvm.io | bash -s stable
if [ -f ~/.rvm/scripts/rvm ]; then
  source ~/.rvm/scripts/rvm
else
  source /etc/profile.d/rvm.sh
fi

rvm install 2.2.3
gem install bundler

bundle
rake db:create
rake db:migrate

cat <<EOF
*****
Next steps:
1. Create a published service for port 3000 on this VM
2. Create config/application.yml - see config/application.yml.example
3. Run: rails r Template.pull
4. Run rails s -b 0.0.0.0
EOF