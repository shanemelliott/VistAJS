#!/bin/sh
FILE=~/vista/dat/vista/IRIS.DAT
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
    # using a compacted version of this file so the community version of VistA works.
    # sudo wget -P ~/vista/dat/vista https://foia-vista.worldvista.org/DBA_VistA_FOIA_System_Files/DBA_VISTA_FOIA_2022/DBA_VISTA_FOIA_20220907.zip
    # sudo unzip ~/vista/dat/vista/DBA_VISTA_FOIA_20220907.zip -d ~/vista/dat/vista
    sudo wget -P ~/vista/dat/vista https://iris-1-3-13.s3.us-west-2.amazonaws.com/DBA_VISTA_FOIA_COMP_20220907.zip
    sudo unzip ~/vista/dat/vista/DBA_VISTA_FOIA_COMP_20220907.zip -d ~/vista/dat/vista
    sudo chmod 775 ~/vista/dat/vista/IRIS.DAT
    sudo chown 51773:51773 ~/vista/dat/vista/IRIS.DAT
    docker-compose up #-d remove comment to not run in shell. 
fi



