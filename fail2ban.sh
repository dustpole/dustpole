#!/bin/bash
# fail2ban.sh


# Check for root
if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

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
			backend = systemd
			[sshd]
			enabled = true
			bantime = 5m
			maxretry = 3
		EOM
	printf "fail2ban configured"
fi

exit 0
