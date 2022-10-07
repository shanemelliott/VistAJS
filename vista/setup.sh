#!/bin/sh
mkdir ~/vista/
mkdir ~/vista/merge/
cp merge.cpf ~/vista/merge/merge.cpf
mkdir ~/vista/dat
mkdir ~/vista/dat/vista
sudo chown -R 51773:51773 ~/vista
sudo chmod 775 ~/vista
#cd ~/vista/dat/vista
sudo wget -P ~/vista/dat/vista https://foia-vista.worldvista.org/DBA_VistA_FOIA_System_Files/DBA_VISTA_FOIA_2022/DBA_VISTA_FOIA_20220907.zip
sudo unzip ~/vista/dat/vista/DBA_VISTA_FOIA_20220907.zip -d ~/vista/dat/vista
sudo chmod 775 ~/vista/dat/vista/IRIS.DAT
docker-compose up -d
./xinetd.sh