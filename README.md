# VistAJS
This is a javascript version of VistA RPC broker from [eHMP](https://github.com/KRMAssociatesInc/eHMP).  It can be used to make RPC calls against VistA. 

after setting up codespaces (outlined below) and creatign a config.js file, try:
```
   node examples.js

```

# Codespace verision of VistA. 

This repository has an implementation that will run the FOIA version of VistA for testing VistAJS. See the /vista directory in the repo. 

  - run setup.sh to download the FOIA version of VistA and start community version of Intersytems IRIS. 
  - Unfortunatly the VA has made the FOIA Version of VistA too large for the community version of Intersystems IRIS. I have compacted the latest version and this repo uses that by default (2022_09_07).  But you can use any version of VistA you would like or uncomment the FOIA version if you have a licnesed version of iris. 
  
   - ** Update - I have been talking to the VA staff thatreleases FOIA version about defragging / compacting / truncating it before posting.  
  - To RESET VistA back to the begiining run the reset.sh script.

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
  - Or some shortcuts from the bash shell:
    - vista: launches the M shell in the VISTA db.
    - iris: launches a bash shell in the iris docker container.


# Xinetd

The VistA setup in this repo uses Xinted for RPC Broker and VistaLink.  There is one change necessare if you switch from the community version to a licnesed version of Iris.  irissession is located in a different location for each.  look for more info in the stg_rpc and stg_vlk files in the vista directory.

# FOIA and Access / Verify Code

 - The JS library in this repo will not work with the FOIA version of Vista.  It has to do with the FOIA version not having the VA encryption. More information can be found [here](https://groups.google.com/g/hardhats/c/egI15djGp5A/m/ZuWf785pQy0J).  I have included a copy from this thread in this repo [xusrb1.xml](/vista/xusrb1.xml).  I will post a script to import and compile but you can do manually for now.  

 - ** update: log into the iris container with 'iris' from a bash shell in vscode, then run '/tmp/xusrb1fix.sh'


# ToDo

 - [x] Fix FOIA Acces/Verify Code issue. 

 - [ ] I will be adding the creatino of an account and the use of VistAJS to this VistA system look for work in the src directory. I am using some work from [VistA FHIR dataloader](https://github.com/WorldVistA/VistA-FHIR-Data-Loader)
  - [ ] For some reason when you run setup.sh sometimes it does not launch IRIS correctly, running docker compse up a second time works. Need to look into this. 

    