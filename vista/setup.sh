#!/bin/sh
# Location of VestA DAT File
FILE=~/vista/dat/vista/IRIS.DAT
# FOIA Version: DBA_VISTA_FOIA_2022/DBA_VISTA_FOIA_20220907.zip
# Compact FOIA Version:DBA_VISTA_FOIA_COMP_20220907.zip
# Internal Version: iris-dat.zip
# Internal newer version (needs to be renamed - see below): iris.zip
# s3 URL: iris-1-3-13.s3.us-west-2.amazonaws.com
# FOI URL: foia-vista.worldvista.org/DBA_VistA_FOIA_System_Files/DBA_VISTA_FOIA_2022/
URL=iris-1-3-13.s3.us-west-2.amazonaws.com
#URL=foia-vista.worldvista.org/DBA_VistA_FOIA_System_Files/DBA_VISTA_FOIA_2022/
ZIP=DBA_VISTA_FOIA_COMP_20220907.zip
#ZIP=DBA_VISTA_FOIA_20220907.zip
#ZIP=iris.zip
#ZIP=iris-dat.zip

is_healthy() {
    service="$1"
    container_id="$(docker-compose ps -q "$service")"
    health_status="$(docker inspect -f "{{.State.Health.Status}}" "$container_id")"

    if [ "$health_status" = "healthy" ]; then
        return 0
    else
        return 1
    fi
}


if [ -f "$FILE" ]; then
     echo "VistA db exists skipping initial setup"
    docker-compose up  -d #-d remove comment to not run in shell. 
else 
    mkdir ~/vista/
    mkdir ~/vista/merge/
    cp merge.cpf ~/vista/merge/merge.cpf
    mkdir ~/vista/dat
    mkdir ~/vista/dat/vista
    sudo chown -R 51773:51773 ~/vista
    sudo chmod 775 ~/vista
    sudo wget -P ~/vista/dat/vista https://$URL/$ZIP
    sudo unzip ~/vista/dat/vista/$ZIP -d ~/vista/dat/vista
    sudo rm ~/vista/dat/vista/$ZIP
    # for another version of VistA
    #sudo mv ~/vista/dat/vista/IRIS.old ~/vista/dat/vista/IRIS.DAT
    sudo chmod 775 ~/vista/dat/vista/IRIS.DAT
    sudo chown 51773:51773 ~/vista/dat/vista/IRIS.DAT
    cp ./bashrc ~/.bashrc
    docker-compose up -d --build
    echo "waiting for iris to start..... this may take a minute.."
    echo "source your .bashrc file to add aliases"
    while ! is_healthy iris; do sleep 1; done
    echo "iris up importing some routines (see access/verify in readme)"
    docker exec iris /tmp/xusrb1fix.sh > /dev/null
    read -p "Import initial user? (y/n)" CONT
    if [ "$CONT" = "y" ]; then
        echo "Creating user with Access Code:VISTAJS123 / Verify Code:VISTAJS123!!";
        # Import sctip and run. :TODO:
        docker exec iris /tmp/CreateUser.sh > /dev/null
    else
    echo "ok then, all set up";
    fi
    read -p "Run VistJS Sample?" CONT
    if [ "$CONT" = "y" ]; then
        cd ..
        node .
    else
    echo "ok";
    fi
fi
   



