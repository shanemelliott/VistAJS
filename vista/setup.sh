#!/bin/sh
FILE=~/vista/dat/vista/IRIS.DAT
# FOIA Version: DBA_VISTA_FOIA_2022/DBA_VISTA_FOIA_20220907.zip
# Compact FOIA Version:DBA_VISTA_FOIA_COMP_20220907.zip
# Internal Version: iris-dat.zip
# s3 URL: iris-1-3-13.s3.us-west-2.amazonaws.com
# FOI URL: foia-vista.worldvista.org/DBA_VistA_FOIA_System_Files/DBA_VISTA_FOIA_2022/
URL=iris-1-3-13.s3.us-west-2.amazonaws.com
#URL=foia-vista.worldvista.org/DBA_VistA_FOIA_System_Files/DBA_VISTA_FOIA_2022/
ZIP=DBA_VISTA_FOIA_COMP_20220907.zip
#ZIP=DBA_VISTA_FOIA_20220907.zip
#ZIP=iris.zip
#ZIP=iris-dat.zip
if [ -f "$FILE" ]; then
    docker-compose up #-d remove comment to not run in shell. 
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
    #sudo mv ~/vista/dat/vista/IRIS.old ~/vista/dat/vista/IRIS.DAT
    sudo chmod 775 ~/vista/dat/vista/IRIS.DAT
    sudo chown 51773:51773 ~/vista/dat/vista/IRIS.DAT
    cp ./bashrc ~/.bashrc
    # remove the -d to run in shell to see any error messages if things are not working. 
    docker-compose up 
fi



