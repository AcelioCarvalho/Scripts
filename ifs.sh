#!/bin/bash
# Por: Acélio Carvalho
# Nome: Immutable File Scanning
# Objetivo: Verificar arquivos imutaveis antes de qualquer atualizações do BBOS.

find /etc/ /usr/lib/systemd/system/ /opt/addons/ /opt/omne/apply/ /opt/omne/conf/ /opt/omne/bin/ /opt/omne/admin/ajax/ /opt/omne/admin/apps/ ! -path /etc/resolv.conf -type f -not -name "*.png" > files.txt

messages=""

total_files=$(wc -l < files.txt)
current_file=0

echo "Verificando arquivos ..."

while IFS= read -r find; do
    ((current_file++))
    
    percentage=$((current_file * 100 / total_files))
    echo -ne "Progresso: [$percentage%]\r"

    if [ "$(lsattr -d "$find" | awk '{print $1}' | grep "i")" ]; then
        messages+="Arquivo imutável: $find"$'\n'
    fi
done < files.txt

echo

echo "$messages"

rm -f files.txt
