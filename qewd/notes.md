https://github.com/robtweed/qewd-starter-kit-iris-networked

1) copy qewd from :
        git clone https://github.com/chrisemunt/mgsi
        to: ~/vista/qewd
2) Install
        zn "%SYS"
        d $system.OBJ.Load("/dur/mgsi/isc/zmgsi_isc.ro","ck")
3) run: default port (7041):
        zn "%SYS"
        d start^%zmgsi(0)

4) Install qewd install directory.       
        sudo git clone https://github.com/robtweed/qewd-starter-kit-iris-networked    
        sudo mv qewd-starter-kit-iris-networked//docker-linux qewd
        sudo rm -rf qewd-starter-kit-iris-networked/
5) edit config file
6) Advertize port on iris.
7) docker pull rtweed/qewd-server
    docker run -it --name qewd --rm -p 3000:8080 -v /home/codespace/vista/qewd:/opt/qewd/mapped rtweed/qewd-server


docker run -it --name qewd --rm --net=vista_default -p 3000:8080 -v /home/codespace/vista/qewd:/opt/qewd/mapped rtweed/qewd-server
  "qewd": {
    "port": 8080,
    "poolsize": 2,
    "managementPassword": "secret",
    "database": {
      "type": "dbx",
      "params": {
        "database": "IRIS",
        "host": "172.18.0.1",
        "tcp_port": 7041,
        "username": "_SYSTEM",
        "password": "",
        "namespace": "VISTA"
      }
    }
  },