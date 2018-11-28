#!/bin/bash
set -euo pipefail

########################
### SCRIPT VARIABLES ###
########################

# Internal domain name (VPN)
INTERNAL_DOMAIN_NAME="devdomain.tk"

# Name of the user to create and grant sudo privileges
## USERNAME=sammy
USERNAME=main

# Password of the user to create and grant sudo privileges
PASSWORD="abc123"

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
	"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCe7ojg0TN8BFxM/g3AHI+FUomki3SoePBHeXXXCWpqAaSBZ3XfqfKY6aZaV0axTR1grjkBy8MjuxQqCwitqNllAdrM7MskcpQz7elUmUE0rXhlSqWcp+U7vZiEnRcQzrHD2E4545B/F7RKoxTCkioSusPEA0guf6weZY3/gZm+EpqIFHYngFmYETjO3xMpSV2PvRFICzm16n1Gv+J7/sbQtRBDPoxWvY7Uszc3XV/7Yz66HYC8S76xLO3Q4HB2kebvxZ/xEuWwlFs3rMSHY0IuVz5+03MSADccyhNpvNM6D6FnIMuEu8oFJxBsVnFHF6B53KnMmtE7tYVoCxZMso7 root@main-server"
)

# SSH public key
SSH_PUBLIC="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDd+PSVvCsSiE/k1IBeG1aL/l4eZKTGcgzZ9xfogI+UONcrdxymX/goaORKMQwl6W/SPAW2yg0BN+o17HkIxssTptCHpX8czfkXOW4/wW26vq7w4X9lueihnrp3IzKlYLtfPCf69uK58bKRWZuuTz8EJYuVBV73GdcM4LHoRf+3FOew+rGZwKrMBsIN63WK68+obzaBz2gTYZxJAnyzOWPIK2c+nlWHkjMHlN/3Eyy1fo08GJKNbhH83YFjc9gfEQYQiCq2wLlAaHqFOqGLsNzn2to3P4DkVaKyL6qWSIrpIuxFryd4hb94Qx4iHCghvvvc+JpF+iZlO3Tko4/Q0Gy9 ansible@dev-ubuntu-01"

# SSH private key
SSH_PRIVATE="$(cat <<- EOM
	-----BEGIN RSA PRIVATE KEY-----
	MIIEpQIBAAKCAQEA3fj0lbwrEohP5NSAXhtWi/5eHmSkxnIM2fcX6ICPlDjXK3cc
	pl/4KGjkSjEMJelv0jwFtsoNATfqNex5CMbLE6bQh6V/HM35FzluP8Ftur6u8OF/
	ZbnooZ66dyMypWC7Xzwn+vbiufGykVmbrk8/BCWLlQVe9xnXDOCx6EX/txTnsPqx
	mcCqzAbCDet1iuvPqG82gc9oE2GcSQJ8szljyCtnPp5Vh5IzB5Tf9xMstX6NPBiS
	jW4R/N2BY3PYHxEGEIgqtsC5QGh6hTqhi7Dc59raNz+A5FWisi+qlkiK6SLsRa8n
	eIW/eEMeIhwoIb773PiaRfomZTt05KOP0NBsvQIDAQABAoIBAQDbC89JaBxVOIEm
	/vECbRX2Jnl4orbcQjYebjGAtkV57rGfafay1GfOcNw/vrEPRJKds6+r1y4IMsaE
	mixClfJXHToRcibDJRuXaIw8jEQdkgiPGugeWdyQiVPXN7vF6XReIb4Occ4B0tr1
	hqkT1Y4JKIfa8ibpz+0g/ydxYIpdfoQEZUtnCzUswc5v0KsVTPwPP6yUDz9MwxFz
	ub03+ZrW3kWIqQQmdyxcWxRZL7Nowie8WqVpjIc7SqsQ6cIjInfP45t/KpWrBgEI
	hg0bEDnBVT5k4azi1XcERu0hh66bhpO5NPp5xZ7OSEO8HgN7LQ4hHE4ueOwG+3Iz
	5oJfl5j9AoGBAPXgK/PgGPbk4nBfYqCxVcz8Jy0sFf0pI4x7ncb3oeZ8jxA//uFV
	o6rNx+NZArHYoVgUqo3VRqc9eUy4kh58m8uTsPweT8CCMUm8ihjYTvtAV5l7txus
	IaA7pxz5SA6tHQ6c+tgbb92UjxvkEnWAiEowF5Nz/gG+PLHUn9ZWmXnDAoGBAOcc
	0KhjY0cEG/1o0rkL44SZCW1yeoaKXHgYLaAX7fHuU8Lsh+oHrsh+7pg1T0sEG/Ek
	pkOPznYWzfvl7PFmjrFiS0WPFFSbScZgdA80snuMwAjoNvPmr9wfi1yskSTA6Kbt
	ajz6WvUrzPxtDG07EtV7a92RI2+cyeGcpx4ECZd/AoGBAJrBEsj3lp7nJwK1dp1P
	oIJZfsr2wYxK9V35fC/8MsGgSmde8Cyhu1bJGHOm1YRcpgiLUWHeCA9BKPS6AvX/
	VgvHFJFK/sVa7GzNp1nF48hOEhS/glt/dtakVSVuXQUnvm8xLM0ST9F2LLDQVzHv
	yVhwdpZPXmN4ejkva777WLQDAoGBAKKZzmA6lNWZGYw/3MoeiDN5bH2ZZoUUAZzo
	/ei+DUYCtOHWgoVwZFNhosJp92DDAlm1vFiaa9r/jmrkyMDKtCgvDOBimx4vp0cw
	A1fTbqOoUk+x+T++lQodE3LfYrrmEomnTfCa/7Ww3GbY3j5XqpeSX0Ci5biYKh1W
	lulyU8FHAoGAZY+KJaHbAVhK4P7IBGG3Nye8mmcTtNxWplMNLtua2WGPyVh+HHqF
	Eo5UesTuLp3yOdqpkVN8DntGVHqXcZLLI2u14a5s64g+ZpNy8mbCFRwSWll0P7R2
	LTk5Br54JnlYBJXKcCZNDlrCisKtdu/Xhz0cn+9QXoqixtCCBzK7AvY=
	-----END RSA PRIVATE KEY-----
EOM
)"

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
# Allow SSH be accessible
ufw allow 22
# Allow Puppet be accessible
ufw allow 9463
ufw --force enable

apt autoremove -y

echo "$SSH_PRIVATE" > "/home/$USERNAME/.ssh/id_rsa"
echo "$SSH_PUBLIC" > "/home/$USERNAME/.ssh/id_rsa.pub"

chmod 600 "/home/$USERNAME/.ssh/id_rsa"
chmod 644 "/home/$USERNAME/.ssh/id_rsa.pub"

chown --recursive "${USERNAME}":"${USERNAME}" "/home/$USERNAME/.ssh"

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
###       CHEF       ###
########################

cd ~
wget https://packages.chef.io/files/stable/chef-server/12.18.14/ubuntu/18.04/chef-server-core_12.18.14-1_amd64.deb

sudo dpkg -i chef-server-core_*.deb

sudo chef-server-ctl reconfigure

sudo chef-server-ctl user-create admin admin admin admin@example.com abc456 -f admin.pem

sudo chef-server-ctl org-create cheforg "DigChef Organization" --association_user admin -f cheforg-validator.pem


echo "Setup Finished" >> "/home/$USERNAME/setup.log"
