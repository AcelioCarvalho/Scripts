#!/bin/bash
# By: Acelio Silva
# Add SSL cert and key to repo files

license=$(/usr/bin/sudo /usr/bin/cat /opt/gsm/backend/etc/.lic |/usr/bin/cut -d ' ' -f 5|/usr/bin/sed 's/[\",]//g')

if [ -n "$license" ]; then

        repo=$(ls /etc/yum.repos.d/*.repo)
        for file in $repo ; do
                if ! grep "sslverify=1" $file &>/dev/null; then
                        sed -i "s/sslverify=0/sslverify=1/g" $file
                        sed -i "/sslverify=1/a sslclientkey=\/opt\/cert\/$license\/$license.key" $file
                        sed -i "/sslverify=1/a sslclientcert=\/opt\/cert\/$license\/$license.crt" $file
                        sed -i "/sslverify=1/a sslcacert=\/opt\/cert\/BlockBitCA.crt" $file
                        echo "$file \| changed"
                else
                        echo "$file \| nothing to do"
                fi
        done
else 
                        echo "license not found"
fi
