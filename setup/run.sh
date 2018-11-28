#!/bin/bash
set -e

# Example to download git repo and use its files
# Make sure:
# 1) There's a puppet server (setup/puppet.sh) with exposed port 8140 to the agents
# 2) The server is viewed as having the puppet domain by the agents (in this example, the full hostname is puppet.devdomain.tk)
# 3) There is at least 1 agent (setup/host.sh) with port 80 opened to public internet
# $ git clone https://github.com/lucasbasquerotto/puppet-demo
# $ sudo mkdir /app
# $ sudo mv puppet-demo/* /app/

sudo cp -R /app/modules/* /etc/puppetlabs/code/modules/
sudo cp /app/manifests/default.pp /etc/puppetlabs/code/environments/production/manifests/site.pp

sudo /opt/puppetlabs/bin/puppet cert list

sudo /opt/puppetlabs/bin/puppet cert sign --all

sudo /opt/puppetlabs/bin/puppet cert list
sudo /opt/puppetlabs/bin/puppet cert list -all