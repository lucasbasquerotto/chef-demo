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

# Git repository where is the chef repo
GIT_REPO='https://github.com/lucasbasquerotto/chef-demo.git'

# shellcheck source=/dev/null
source ~/.bash_profile

# Chef Repo name in git directory
# CHEF_REPO_NAME='chef-repo'
CHEF_REPO_NAME='chef-repo-101'

cd ~
git clone "$GIT_REPO"
mkdir chef-repo
shopt -s dotglob
mv chef-demo/"$CHEF_REPO_NAME"/* chef-repo/

rm -rf chef-demo

git config --global user.name "Chef User"
git config --global user.email "chef@domain.com"

echo ".chef" >> ~/chef-repo/.gitignore

# cd ~/chef-repo
# git add .

# git commit -m "Excluding the ./.chef directory from version control"

scp -o StrictHostKeyChecking=no $CHEF_SERVER_USER_NAME@$CHEF_SERVER_FQDN:/home/$CHEF_SERVER_USER_NAME/$CHEF_ADMIN_NAME.pem ~/chef-repo/.chef
scp -o StrictHostKeyChecking=no $CHEF_SERVER_USER_NAME@$CHEF_SERVER_FQDN:/home/$CHEF_SERVER_USER_NAME/$CHEF_ORG_NAME-validator.pem ~/chef-repo/.chef

cd ~/chef-repo
knife ssl fetch

# cd ~/chef-repo
# Verification: $ knife client list
# knife bootstrap $node_domain_or_IP -x host -A -P def456 --sudo --use-sudo-password -N $name
# Ex: knife bootstrap worker-001.kube -x host -A -P def456 --sudo --use-sudo-password -N worker-001
# 
# Add the Cookbook to your Node
# $ knife cookbook upload -a
# $ export EDITOR=nano
# $ knife node edit worker-001
# ( "run_list": [ "recipe[main]" ] )
# $ ssh host@worker-001.kube
# $ sudo chef-client
# ( http://node_domain_or_IP )