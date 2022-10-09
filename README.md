# VistAJS
This is a javascript version of VistA RPC broker.  It can be used to make RPC calls against VistA. 

# Codespace verision of VistA. 

This repository has an implementation that will run the FOIA version of VistA for testing VistAJS. see the /vista directory in the repo. 

 - run setup.sh to download the FOIA version of VistA and start community version of Intersytems IRIS. 
  - Unfortunatly the VA has made the FOIA Version of VistA too large for the community version of Intersystems IRIS. I have compacted the latest version and this repo uses that by default (2022_09_07).  But you can use any version of VistA you would like or uncomment the FOIA version if you have a licnesed version of iris.

  # Accessing Management portal of Intersystems

  Once you have intersystems running, to access the management portal, check the ports assigned.

  - Find the url for the 52773 port.
  - Right mouse click and select open in browser.  Add /csp/sys/UtilHome.csp to the url. (see https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GSA_using_portal#GSA_using_portal_start for more info)
  - log in with _SYSTEM and password SYS

  # Logging into VistA

  - You can log into VistA with the following command: 

``
   docker exec -it iris iris session iris -U VISTA '^ZU'
``

# ToDo

 - I will be adding the creatino of an account and the use of VistAJS to this VistA system.
 - For some reason when you run setup.sh sometimes it does not launch IRIS correctly, running docker compse up a second time works. Need to look into this. 

    