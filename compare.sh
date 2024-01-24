for i in \
    "/etc/postfix/master.cf" \
    "/etc/postfix/ad_virtual_mailbox_maps.cf" \
do
   printf($i)
done
