#!/usr/bin/env bash

while IFS=: read -r username _ uid _; do
    if [ "$uid" -ge 1000 ]; then #if uid is greater than or equal to 1000
        usermod $username -s /sbin/nologin;
    	echo "$username, user set to no login";
    fi
done < /etc/passwd
