#!/bin/bash
# Por: Acélio Carvalho
# Nome: Scanning Immutable Files
# Objetivo: Verificar arquivos imutaveis antes de qualquer atualizações do BBOS.

# Encontrar arquivos e salvar em files.txt
find /etc/ /usr/lib/systemd/system/ /opt/addons/ /opt/omne/apply/ /opt/omne/conf/ /opt/omne/bin/ /opt/omne/admin/ajax/ /opt/omne/admin/apps/ ! -path /etc/resolv.conf -type f -not -name "*.png" > files.txt

total_files=$(wc -l < files.txt)
current_file=0

echo "Verificando arquivos ..."

# Loop através dos arquivos em files.txt
while IFS= read -r find; do
    ((current_file++))

    # Exibir barra de progresso
    percentage=$((current_file * 100 / total_files))
    echo -ne "Progresso: [$percentage%]\r"

    if [ "$(lsattr -d "$find" | awk '{print $1}' | grep "i")" ]; then
        echo "Arquivo imutável: $find"
    fi
done < files.txt

# Adicionar nova linha após a barra de progresso
echo

# Limpar o arquivo temporário
rm -f files.txt
