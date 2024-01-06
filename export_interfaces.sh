#!/bin/bash

# Criado por: Acelio Silva
# Exportador de configuração padronizada para importar no servidor secudario do HA 2.4.1.

# Cabeçalho do arquivo modelo csv
echo "Interface de Rede Local, Interface de Rede Virtual, Grupo de Interface, Utilizar protocolo UDP, Monitoramento, Chave de identificacao"

# Lista locais todas interfaces habilitadas e que contem IP.
psql="psql -U postgres brcconfig -t -A -c"
count=0

for vip in `$psql "select name from box_net_device where alias='t' or  virtual='t' and onboot='t' and obj_addr_id IS NOT NULL AND NOT name LIKE '%.%' ORDER BY name"`;do

    # Lista interfaces VIP
    net_local=`echo "$vip" | awk -F "v|:" '{print$1}'`

    # Evitar listar interfaces sem VIP
    if [ -n "$net_local" ]; then

	count=$((count + 1))
 
 	# Evitar que o grupo da interface seja igual o da heartbeat
  	if [ $count = 100 ]; then
                count=$((count + 1))
        fi
	
        # Exibi no farmato csv
        # Interface de Rede Local, Interface de Rede Virtual, Grupo de Interface, Utilizar protocolo UDP, Monitoramento, Chave de identificação
        echo "$net_local, $vip, $count, 0, 1, $(openssl rand -base64 7 | tr -d '+/' | head -c 7)"
    fi
done
