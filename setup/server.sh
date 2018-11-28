#!/bin/bash
set -euo pipefail

########################
### SCRIPT VARIABLES ###
########################

# Internal domain name (VPN)
INTERNAL_DOMAIN_NAME="devdomain.tk"

# Name of the user to create and grant sudo privileges
## USERNAME=sammy
USERNAME=host

# Password of the user to create and grant sudo privileges
PASSWORD="def456"

# Name of the chef admin user
CHEF_ADMIN_NAME=admin

# Password of the chef admin user
CHEF_ADMIN_PASS=abc456

# Name of the chef admin user
CHEF_ORG_NAME=cheforg

# Whether to copy over the root user's `authorized_keys` file to the new sudo
# user.
## COPY_AUTHORIZED_KEYS_FROM_ROOT=true
COPY_AUTHORIZED_KEYS_FROM_ROOT=false

# Specify if it's to add the user to the docker group
# ADD_USER_TO_DOCKER_GROUP=false

# Additional public keys to add to the new sudo user
# OTHER_PUBLIC_KEYS_TO_ADD=(
#	"ssh-rsa AAAAB..."
#	"ssh-rsa AAAAB..."
# )
## OTHER_PUBLIC_KEYS_TO_ADD=()
OTHER_PUBLIC_KEYS_TO_ADD=(
	"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDd+PSVvCsSiE/k1IBeG1aL/l4eZKTGcgzZ9xfogI+UONcrdxymX/goaORKMQwl6W/SPAW2yg0BN+o17HkIxssTptCHpX8czfkXOW4/wW26vq7w4X9lueihnrp3IzKlYLtfPCf69uK58bKRWZuuTz8EJYuVBV73GdcM4LHoRf+3FOew+rGZwKrMBsIN63WK68+obzaBz2gTYZxJAnyzOWPIK2c+nlWHkjMHlN/3Eyy1fo08GJKNbhH83YFjc9gfEQYQiCq2wLlAaHqFOqGLsNzn2to3P4DkVaKyL6qWSIrpIuxFryd4hb94Qx4iHCghvvvc+JpF+iZlO3Tko4/Q0Gy9 ansible@dev-ubuntu-01"
)

####################
### SCRIPT LOGIC ###
####################

# Add sudo user and grant privileges
useradd --create-home --shell "/bin/bash" --groups sudo "${USERNAME}"

# Check whether the root account has a real password set
encrypted_root_pw="$(grep root /etc/shadow | cut --delimiter=: --fields=2)"

if [ -z "${PASSWORD}" ]; then
	if [ "${encrypted_root_pw}" != "*" ]; then
		# Transfer auto-generated root password to user if present
		# and lock the root account to password-based access
		echo "${USERNAME}:${encrypted_root_pw}" | chpasswd --encrypted
		passwd --lock root
	else
		# Delete invalid password for user if using keys so that a new password
		# can be set without providing a previous value
		passwd --delete "${USERNAME}"
	fi

	# Expire the sudo user's password immediately to force a change
	chage --lastday 0 "${USERNAME}"
else
	passwd --delete "${USERNAME}"
	echo "$USERNAME:$PASSWORD" | chpasswd

	echo "New password defined for $USERNAME" >> "/home/$USERNAME/setup.log"

	if [ "${encrypted_root_pw}" != "*" ]; then
		passwd --lock root
	fi
fi

# Create SSH directory for sudo user
home_directory="$(eval echo ~${USERNAME})"
mkdir --parents "${home_directory}/.ssh"

# Copy `authorized_keys` file from root if requested
if [ "${COPY_AUTHORIZED_KEYS_FROM_ROOT}" = true ]; then
	cp /root/.ssh/authorized_keys "${home_directory}/.ssh"
fi

# Add additional provided public keys
for pub_key in "${OTHER_PUBLIC_KEYS_TO_ADD[@]}"; do
	echo "${pub_key}" >> "${home_directory}/.ssh/authorized_keys"
done

# Adjust SSH configuration ownership and permissions
chmod 0700 "${home_directory}/.ssh"
chmod 0600 "${home_directory}/.ssh/authorized_keys"
chown --recursive "${USERNAME}":"${USERNAME}" "${home_directory}/.ssh"

# Disable root SSH login with password
sed --in-place 's/^PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
if sshd -t -q; then
	systemctl restart sshd
fi

# Add exception for SSH and then enable UFW firewall
# ufw allow 22
# ufw allow 6443
# ufw --force enable

apt-get autoremove -y

echo "Main logic finished" >> "/home/$USERNAME/setup.log"

########################
###     VPN DNS      ###
########################

echo "Defining VPN DNS..." >> "/home/$USERNAME/setup.log"

apt install -y resolvconf

touch /etc/resolvconf/resolv.conf.d/head

{ 
	echo "search $INTERNAL_DOMAIN_NAME"
	echo "nameserver 8.8.8.8"
	echo "nameserver 8.8.4.4"
} >> /etc/resolvconf/resolv.conf.d/head

resolvconf -u

echo "VPN DNS Defined" >> "/home/$USERNAME/setup.log"

########################
###   CHEF SERVER    ###
########################

echo "Chef Server instalation started" >> "/home/$USERNAME/setup.log"

{ 
	echo "127.0.1.1 chef-server.$INTERNAL_DOMAIN_NAME chef-server"
	echo "127.0.0.1 localhost"
} > /etc/hosts

cd /home/$USERNAME
wget https://packages.chef.io/files/stable/chef-server/12.18.14/ubuntu/18.04/chef-server-core_12.18.14-1_amd64.deb
#wget https://packages.chef.io/files/stable/chef-server/12.18.14/ubuntu/14.04/chef-server-core_12.18.14-1_amd64.deb

dpkg -i chef-server-core_*.deb

echo "Chef Server package extracted" >> "/home/$USERNAME/setup.log"

chef-server-ctl reconfigure

echo "Chef Server configured" >> "/home/$USERNAME/setup.log"

chef-server-ctl user-create $CHEF_ADMIN_NAME first last $CHEF_ADMIN_NAME@example.com $CHEF_ADMIN_PASS -f $CHEF_ADMIN_NAME.pem

chef-server-ctl org-create $CHEF_ORG_NAME "Chef Organization" --association_user $CHEF_ADMIN_NAME -f $CHEF_ORG_NAME-validator.pem

echo "Chef Server instalation finished" >> "/home/$USERNAME/setup.log"
	
echo "Setup Finished" >> "/home/$USERNAME/setup.log"
