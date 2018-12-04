#!/bin/bash
set -e

# Chef Server FQDN (related to $INTERNAL_DOMAIN_NAME)
CHEF_SERVER_FQDN='chef-server'

# Name of the user in the chef server
CHEF_SERVER_USER_NAME="host"

# Name of the chef admin user
CHEF_ADMIN_NAME='admin'

# Name of the chef admin user
CHEF_ORG_NAME='cheforg'

# Location of the knife.rb file
CONFIG_ORIGIN='https://raw.githubusercontent.com/lucasbasquerotto/chef-demo/master/chef-repo/.chef/knife.rb'

# shellcheck source=/dev/null
source ~/.bash_profile

cd ~
git clone https://github.com/chef/chef-repo.git

git config --global user.name "Chef User"
git config --global user.email "chef@domain.com"

echo ".chef" >> ~/chef-repo/.gitignore

cd ~/chef-repo
git add .

git commit -m "Excluding the ./.chef directory from version control"

mkdir ~/chef-repo/.chef

wget "$CONFIG_ORIGIN" --directory-prefix="$HOME/chef-repo/.chef/"

scp -o StrictHostKeyChecking=no $CHEF_SERVER_USER_NAME@$CHEF_SERVER_FQDN:/home/$CHEF_SERVER_USER_NAME/$CHEF_ADMIN_NAME.pem ~/chef-repo/.chef
scp -o StrictHostKeyChecking=no $CHEF_SERVER_USER_NAME@$CHEF_SERVER_FQDN:/home/$CHEF_SERVER_USER_NAME/$CHEF_ORG_NAME-validator.pem ~/chef-repo/.chef

cd ~/chef-repo
knife ssl fetch

# Verification: $ knife client list
# knife bootstrap $node_domain_or_IP -x host -A -P def456 --sudo --use-sudo-password -N $name
# Ex: knife bootstrap worker-001.kube -x host -A -P def456 --sudo --use-sudo-password -N worker-001
# 
# Add the Cookbook to your Node
# $ knife cookbook upload -a