#!/bin/bash

# Check for root
if [ $(whoami) != "root" ]; then
    echo "Script must be run as root"
    exit 1

if [[ "$ID" == "fedora" && $VERSION_ID -gt 21 ]] || \
then

	# Install failban
	sudo yum install fail2ban -y
	printf "Installed fail2ban"

	# Install and configure fail2ban
	sudo systemctl enable fail2ban
	sudo systemctl start fail2ban
	printf "fail2ban Enabled/Started"
	
		cat > /etc/fail2ban/jail.local <<- EOM
			[sshd]
			enabled = true
			bantime = 5m
			maxretry = 3
		EOM
printf "fail2ban configured"
fi

exit 0