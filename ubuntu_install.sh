#!/bin/bash

# Install script - Tested on Ubuntu 14.04 ONLY
set -e 

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo -y apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev libgdbm-dev libncurses5-dev automake libtool bison libffi-dev libgmp-dev postgresql libpq-dev nodejs libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
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

# Assuming this repo has been checked out!
# git clone https://bitbucket.org/mhgoldman/demo_creator
# cd demo_creator/
bundle
rake db:create
rake db:migrate
whenever -w

echo
echo "*****""
echo "Next steps:"
echo "1) Create config/application.yml (see config/application.yml.example)"
echo "2) rails r Template.pull"
echo "3) rails s"