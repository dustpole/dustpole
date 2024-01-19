#!/bin/bash
# fail2ban.sh

# Check for root
if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

# get some version information
. /etc/os-release


if [[ "$ID" == "fedora" && $VERSION_ID -gt 21 ]]
then
    # try to use fail2ban
    which fail2ban >/dev/null
    if [[ $? -ne 0 ]]
    then
		# Install fail2ban
        yum install fail2ban -y
		printf "Installed fail2ban"
	fi
	
	# Configure fail2ban
	sudo systemctl enable fail2ban
	sudo systemctl start fail2ban
	printf "fail2ban Enabled/Started"
else
    printf "${error}ERROR: Fail2ban did not install or start.${reset}\n"
    exit 1
fi	
	
cat > /etc/fail2ban/jail.local <<- EOM
	backend = systemd
	[sshd]
	enabled = true
	bantime = 5m
	maxretry = 3
	EOM
printf "fail2ban configured"

exit 0
