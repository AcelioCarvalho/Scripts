#!/bin/bash
#Por: Acelio Silva
#Email: asilva@blockbit.com

if [ ! -f /opt/omne/conf/.wizard ]; then echo "Uncofigured server"; exit; fi

status=`/usr/bin/sudo /usr/bin/systemctl is-active strongswan`

if [ "$status" != "active" ]; then echo "Service is disabled"; exit; fi

data=$(echo "id_tun | child_sa | state | name")
separator="----------+-----------+--------------+------------------------------------"
printf "%-9s | %-9s | %-12s | %-20s\n" "id_tun" "child_sa" "state" "name"
echo $separator

for id in $(/usr/bin/sudo /usr/sbin/swanctl --list-sas --raw | /bin/cut -d '{' -f2 | /bin/grep -Ev '}|unnamed'| /bin/sort | /bin/uniq -c | /bin/sort -rn | /bin/awk '{print $1 "-" $2}'); do
        id_tun=$(echo "$id" | /bin/cut -d "n" -f 2)
        name=$(/bin/grep -E "#" /etc/strongswan/swanctl/conf.d/tunnel$id_tun.conf | /bin/cut -d "#" -f2)
        qnt=$(echo "$id" | /bin/cut -d "-" -f 1)
        if ! /usr/bin/sudo /usr/sbin/strongswan status tun$id_tun | grep "ESTABLISHED" &>/dev/null
         then
                state="CONNECTING"
        else
                state="ESTABLISHED"
        fi
        printf "%-9s | %-9s | %-12s | %-20s\n" "tun$id_tun" "$qnt" "$state" "$name"
done
