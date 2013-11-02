#!/bin/bash
#find hostnames on a given IP
rm -f /tmp/hosts
rm -f /tmp/temp_hosts
if [ "$1" != "" ]; then
ip=$(ping -c1 $1 | cut -d\  -f5 | grep ".*\..*\." | sed 's/^.//;s/..$//;s/\ //')
rm -f /tmp/temp_hosts && wget -O /tmp/temp_hosts http://www.my-ip-neighbors.com/?domain=$1 2>/dev/null
cat /tmp/temp_hosts | grep 'whois.domaintools.com' | sed 's/^.*com\///g;s/\".*//' > /tmp/hosts
rm -f /tmp/temp_hosts
echo "registered hostname on $ip ($1) :"
cat /tmp/hosts
echo "checking which are online..."
old_IFS=$IFS
IFS=$'\n'
for line in $(cat /tmp/hosts)
do
  ip2=$(ping -c1 $line 2>/dev/null | cut -d\  -f5 | grep ".*\..*\." | sed 's/^.//;s/..$//')
  if [ "$ip" = "$ip2" ]
    then echo "$line OK !"
  fi
done
IFS=$old_IFS
rm -f /tmp/hosts
else
echo "Usage : $0 HOSTNAME";
fi
