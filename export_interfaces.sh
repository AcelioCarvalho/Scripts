#!/bin/bash

# Criado por: Acelio Silva
# Exportador de configuração padronizada para importar no servidor secudario do HA 2.4.1.

# Cabeçalho do arquivo modelo csv
echo "Interface de Rede Local, Interface de Rede Virtual, Grupo de Interface, Utilizar protocolo UDP, Monitoramento, Chave de identificação"

# Lista todas interfaces habilitadas e que contem IP.
psql="psql -U postgres brcconfig -t -A -c"
count=0

for net in `$psql "select name from box_net_device where alias='f' and onboot='t' and obj_addr_id IS NOT NULL AND NOT name LIKE '%v%';" | sort`; do 

    # Lista interfaces alias sobre as interfaces fisicas e VLAN
    vip=`$psql "select name from box_net_device where alias='t' and onboot='t' and obj_addr_id IS NOT NULL and name like '$net:%';"`

    # Listar interfaces Virtuais porem com descrição que contem  a palavra VIP.
    if [ -z "$vip" ]; then

        vip=`$psql "select name from box_net_device where virtual='t' and onboot='t' and obj_addr_id IS NOT NULL and name like '$net%v%' and full_description  ilike '%vip%';"`
    fi

    # Evitar listar interfaces sem VIP
    if [ -n "$vip" ]; then

	count=$((count + 1))
        
        # Exibi no farmato csv
        # Interface de Rede Local, Interface de Rede Virtual, Grupo de Interface, Utilizar protocolo UDP, Monitoramento, Chave de identificação
        echo "$net, $vip, $count, 0, 0, $(openssl rand -base64 7 | tr -d '+/' | head -c 7)"
    fi
done
