#!/bin/bash
curl -O http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest
grep 'apnic|JP|ipv4' delegated-apnic-latest | awk -F'|' '{printf("%s/%d\n", $4, 32-log($5)/log(2))}' > jp_ipv4.txt
firewall-cmd --permanent --new-ipset=jp --type=hash:net
firewall-cmd --permanent --ipset=jp --add-entries-from-file=jp_ipv4.txt
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source ipset="jp" service name="http" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source ipset="jp" service name="https" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source ipset="jp" service name="ssh" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source ipset="jp" port port="8080" protocol="tcp" accept'
firewall-cmd --permanent --zone=public --set-target=DROP
firewall-cmd --reload