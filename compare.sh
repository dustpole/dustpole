for i in \
    "/etc/postfix/master.cf" \
    "/etc/postfix/ad_virtual_mailbox_maps.cf" \
do
   diff <(cat %i) <(cut -f2 /opt/bak/%i)
done
