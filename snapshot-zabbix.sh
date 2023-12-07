#!/bin/bash
# Por: Acélio Carvalho

# Definindo variáveis
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="zabbix"
DB_USER="zabbix"
DB_PASS=""
BACKUP_DIR="/root"

# Nome do arquivo de backup
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/zabbix-6.4-$DB_NAME_backup_$DATE.sql"


# Escolhendo a ação
echo "Selecione uma opção:"
echo "1 - Fazer backup"
echo "2 - Restaurar backup"
read -p "Opção: " option

# Fazendo backup
if [ $option -eq 1 ]; then
  echo "Fazendo backup..."
  # Configuração do arquivo .pgpass
  PGPASS_FILE="$HOME/.pgpass"
  echo "$DB_HOST:$DB_PORT:$DB_NAME:$DB_USER:$DB_PASS" > $PGPASS_FILE
  chmod 600 $PGPASS_FILE

  PGPASSFILE=$PGPASS_FILE pg_dump -U $DB_USER -h $DB_HOST -d $DB_NAME -f $BACKUP_FILE
  # Remover o arquivo .pgpass após o uso
  rm $PGPASS_FILE
  # Verifica se o backup foi criado com sucesso
    if [ $? -eq 0 ]; then
        echo "Backup do banco de dados $DB_NAME realizado com sucesso em $BACKUP_FILE"
    else
        echo "Erro ao realizar o backup do banco de dados $DB_NAME"
    fi
fi

# Restaurando backup
if [ $option -eq 2 ]; then
  echo "input file or directory name"
  read -p "file: " FILENAME
  if [ -n "$FILENAME" ]; then
    echo "Restaurando backup..."
    sudo -u postgres psql $DB_USER < $FILENAME &>/dev/null
    echo "Backup restaurado com sucesso!"
  else
    echo "Arquivo de backup invalido"
    exit 0
  fi
fi
