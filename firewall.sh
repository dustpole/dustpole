#!/bin/bash
# 
# firewall.sh
# 
# Quick script to get firewall going. No extra features,
# raw, pure, defense only.
# 
# Works with iptables and firewalld
# Prefers to use iptables
#
# Kaicheng Ye
# Dec. 2023
# Modified of webmail and Fedora 21
# Dustin Pollreis
# Jan. 2024

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting firewall script${reset}\n"

# get some version information
. /etc/os-release

# Checking for either iptables or firewalld
if [[ "$ID" == "centos" && $VERSION_ID -gt 6 ]] || \
   [[ "$ID" == "fedora" && $VERSION_ID -gt 21 ]] || \
   [[ "$ID" == "rhel" && $VERSION_ID -gt 6 ]]
then
    # try to use iptables
    which iptables >/dev/null
    if [[ $? -ne 0 ]]
    then
    	$FIREWALL='iptables'
        yum install iptables -y
    fi
	    # try to use iptables-services
    yum check installed iptables-services >/dev/null
    if [[ $? -ne 0 ]]
    then
        yum install iptables-services -y
    fi

printf "Using ${info}$FIREWALL${reset}\n\n"

# Getting set up
    # allow iptables to run
    # check for systemctl
    which systemctl >/dev/null
    if [[ $? -eq 0 ]]
    then
        systemctl unmask iptables
        systemctl enable iptables
        systemctl start iptables
    else
        service iptables enable
        service iptables start
    fi

    # must disable firewalld if it's a thing
    which firewall-cmd >/dev/null
    if [[ $? -eq 0 ]]
    then
        which systemctl >/dev/null
        if [[ $? -eq 0 ]]
        then
            systemctl disable firewalld
            systemctl stop firewalld
            systemctl mask firewalld
        else
            service firewalld stop
            service firewalld disable
        fi
    fi

    # Clearing the rules
    iptables -F
fi


# main loop to block everything


# finishing up
if [[ "$FIREWALL" == "iptables" ]]
    # iptables
    # Accept by default in case of flush
    iptables -P INPUT ACCEPT
    iptables -P OUTPUT ACCEPT

    # Allow basic connections
    # Allow ICMP 
    iptables -A INPUT -p ICMP -j ACCEPT
    iptables -A OUTPUT -p ICMP -j ACCEPT

    # Drop Invalid Packets
    iptables -I INPUT 1 -m conntrack --ctstate INVALID -j DROP

    # Allow outgoing SSH
    iptables -A OUTPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Allow all outgoing http & https
    iptables -A OUTPUT -p tcp -m multiport --dports 80,443,8000,9090 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p tcp -m multiport --sports 80,443,8000,9090 -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Allow outgoing DNS
    iptables -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
 
    # Allow outgoing NTP
    iptables -A OUTPUT -p udp --dport 123 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p udp --sport 123 -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Allow outgoing Splunk
    iptables -A OUTPUT -p tcp --dport 9997 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p tcp --sport 9997 -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Allow outgoing DHCP
    iptables -A OUTPUT -p udp --dport 67 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p udp --sport 67 -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Allow outgoing SMTP
    iptables -A OUTPUT -p tcp -m multiport --dports 25,587,465,2525 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p tcp -m multiport --sports 25,587,465,2525 -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Allow outgoing POP3
    iptables -A OUTPUT -p tcp -m multiport --dports 110,995 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p tcp -m multiport --sports 110,995 -m conntrack --ctstate ESTABLISHED -j ACCEPT
    
    # Allow outgoing MySQL
    iptables -A OUTPUT -p tcp -m multiport --dports 3306 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p tcp -m multiport --sports 3306 -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Allow outgoing IMAP
    iptables -A OUTPUT -p tcp -m multiport --dports 143,993 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p tcp -m multiport --sports 143,993 -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Allow local communication
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT

    # DROP everything else
    iptables -A INPUT -j DROP
    iptables -A OUTPUT -j DROP

    # Backup Rules (iptables-restore < /opt/bak/ip_rules)
	if [[ ! -d /opt/bak ]]
	then
		mkdir -p /opt/bak
	fi

    iptables-save > /opt/bak/ip_rules
    # list rules for review
    iptables -L -v -n
fi

systemctl restart iptables

exit 0
