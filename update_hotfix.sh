#!/bin/bash
#Por: Acélio Carvalho

version=`cut -d " " -f3 /etc/buildstamp | cut -d '.' -f 1-4`

verificar_ha(){

   ha=`/usr/bin/systemctl is-active cluster_ha.service`
   
   if [[ $ha != active ]];then
      echo "Disable HA to continue"
      exit 0
   fi
}

baixar_hotfix() {
        for hf in `curl -sS "https://docs.blockbit.com/display/RC/Hotfixes" | grep -oE '(https://s3.amazonaws.com/repo.blockbit.com/hotfix/([^\"]*)|https://shlink.blockbit.com/\w+)'`; do

        if echo "$hf" | grep "shlink.blockbit.com" &>/dev/null; then
                hf=`curl -s -I -k $hf | sed -n 's/^Location: //p' | sed 's/\r//'`
                
                hotfix=`echo "$hf" | cut -d "/" -f9 | sed "s/\%2F/_/g"`
        else
                hotfix=`echo "$hf" | cut -d "/"  -f 7`
        fi
        if echo "$hf" | grep "$version" &>/dev/null ; then
        curl -s -k -X GET $hf -o $hotfix
        /opt/omne/update_module/bin/omne-bb-update check -p $hotfix | cut -d "," -f 6,7
        /opt/omne/update_module/bin/omne-bb-update install -p $hotfix | cut -d '"' -f 8
        echo -e "\n"
        fi
        done
}

# Menu principal
while true; do
    echo -e "\nEscolha uma opção:"
    echo "1. Instalar todos hotfix"
    echo "2. Listar hotfix instalados"
    echo "3. Remover último hotfix"
    echo "4. Remover todos hotfix"
    echo -e "5. Sair\n"

    read choice

        case $choice in

        1)
                verificar_ha 
                baixar_hotfix
                echo -e "Todos Hotfix instalados\n"
                ;;
        2)
                 echo -e "\nid| description"
                 sqlite3 /opt/omne/update_module/db/database_update.sqlite "select id,description from updates;"
                 echo "              "
                ;;
        3)

                verificar_ha
                last_hf=`sqlite3 /opt/omne/update_module/db/database_update.sqlite --separator ' - ' "select id,description from updates ORDER BY id DESC LIMIT 1;"`

                echo -e "\nRemovendo hotfix: $last_hf"
                /opt/omne/update_module/bin/omne-bb-update rollback &>/dev/null
                echo  -e "Concluído\n"

                ;;

        4)      
                verificar_ha
                desc_hf=`sqlite3 /opt/omne/update_module/db/database_update.sqlite --separator ' - ' "select id,description from updates ORDER BY id DESC;"`
                id=`sqlite3 /opt/omne/update_module/db/database_update.sqlite "select id from updates ORDER BY id DESC;"`

                for id_hf in $id; do
                        desc_hf=`sqlite3 /opt/omne/update_module/db/database_update.sqlite --separator ' - ' "select description from updates where id = $id_hf ;"`

                        echo -e "\nRemovendo hotfix: $id_hf - $desc_hf"


                        /opt/omne/update_module/bin/omne-bb-update rollback | cut -d '"' -f 8
                done
                echo -e "\nTodos hotfix removidos"
                ;;
        5)
                echo "Saindo ..."
                break
                ;;

        *)
            echo "Opção inválida. Tente novamente."
            ;;
    esac
done
