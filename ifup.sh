#!/bin/bash
DEV=${1-eth1}
last_prio=$( ip rule show |awk -F: '{print $1}' |grep -v "^3276" |sort -r | head -1 )
PRIO=$( expr $last_prio + 5 )

ip=$(ip -f inet -o addr show $DEV | cut -d\  -f 7 | cut -d/ -f 1  | head -1)
prefix=$(ip -f inet -o addr show $DEV | cut -d\  -f 7 | cut -d/ -f 2| head -1)
subnet=`ip -f inet -o addr show $DEV | cut -d\  -f 7 | cut -d/ -f 1 |head -1 | awk -F'.' '{printf "%s.%s.%s.0", $1,$2,$3}'`
gw=`ip -f inet -o addr show $DEV | cut -d\  -f 7 | cut -d/ -f 1|head -1 | awk -F'.' '{printf "%s.%s.%s.1", $1,$2,$3}'`

echo "$DEV: IP=$ip GW=$gw SUBNET=$subnet"

latest_rt_number=$( cat /etc/iproute2/rt_tables |egrep -v "^#|^0" | awk '{print $1}' |sort -n | head -1 )
rt_number=$( expr $latest_rt_number - 1 )
if [[ -z "$(cat /etc/iproute2/rt_tables | grep "$rt_$DEV")" ]]; then
	echo "$rt_number	rt_$DEV" |tee -a /etc/iproute2/rt_tables
fi

# Create rules:
ip rule add prio "$PRIO" from $ip table rt_$DEV


if [[ -z "$(ip route show table rt_$DEV |grep "$subnet/$prefix" )" ]]; then
	ip route add "$subnet/$prefix" dev $DEV table rt_$DEV
fi
# Define routing tables:
if [[ -z "$(ip route show table rt_$DEV |grep 'default')" ]]; then
	ip route add default via $gw table rt_$DEV src "$ip" proto static table rt_$DEV
fi

# If we already have a 'nexthop' route, delete it:
if [ ! -z "`ip route show table main | grep 'nexthop'`" ] ; then
	ip route del default scope global
fi

# Flush cache table:
ip route flush cache
