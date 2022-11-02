# VistAJS
This is a javascript version of VistA RPC broker from [eHMP](https://github.com/KRMAssociatesInc/eHMP).  It can be used to make RPC calls against VistA. 


After setting up codespaces (outlined below), try the following.  You can run this from a terminal in the codespace if you are on a browser....OR from your workstation if you are running the codespace in VS Code on your workstation. If you are running the codespace from your workstation the ports are mapped to localhost automatically. 

```
node index.js
```

- Please remember you need a valid user with a valid Access / Verify Code.  Depending on the version of VistA you are using that will vary. 

# Codespace verision of VistA. 

This repository has an implementation that will run the FOIA version of VistA for testing VistAJS. See the /vista directory in the repo. 

  - Run setup.sh to download the FOIA version of VistA and start community version of Intersytems IRIS. *Update: This script will create a generic Provider user and then run VistJS to verify successful install. The routine I used to do this is from https://github.com/WorldVistA/VistA-FHIR-Data-Loader/blob/master/src/SYNINIT.m
  
  - Unfortunatly the VA has made the FOIA Version of VistA too large for the community version of Intersystems IRIS. I have compacted the latest version and this repo uses that by default (2022_09_07).  But you can use any version of VistA you would like or uncomment the FOIA version if you have a licnesed version of iris. 
  
   - ** Update - I have been talking to the VA staff that releases FOIA version about defragging / compacting / truncating it before posting. 

   - **Update - THe latest version of FOIA VistA is now < 10gig.  
   
  - To RESET VistA back to the begiining run the reset.sh script. <-- This deletes everything!

  # Accessing Management portal of Intersystems

  Once you have intersystems running, to access the management portal, check the ports assigned.

  - Find the url for the 52773 port.
  - Right mouse click and select open in browser.  Add /csp/sys/UtilHome.csp to the url. (see https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GSA_using_portal#GSA_using_portal_start for more info)
  - log in with _SYSTEM and password SYS

  # Logging into VistA

  After the setup script has run, source your .bashhrc to add the follwoing aliases or start a new shell.


  - You can log into VistA with the following from the shell prompt.

      ``
        vista
      ``
  
  # Shortcuts

  - You can get to the Mumps direct prompt with the following from the shell prompt. 

      ``
        prog
      ``
  - you can get to the iris container by typing the following from the shell prompt.
  
      ``
        iris
      ``

# Xinetd

The VistA setup in this repo uses Xinted for RPC Broker and VistaLink.  There is one change necessary if you switch from the community version to a licnesed version of Iris.  irissession is located in a different location for each.  Look for more info in the stg_rpc and stg_vlk files in the vista directory.

# FOIA and Access / Verify Code

 - The JS library in this repo will not work with the FOIA version of Vista.  It has to do with the FOIA version not having the VA encryption. More information can be found [here](https://groups.google.com/g/hardhats/c/egI15djGp5A/m/ZuWf785pQy0J).  I have included a copy from this thread in this repo [xusrb1.xml](/vista/xusrb1.xml). Below is a scrit to fix this.  

 - On the Docker container (iris) /tmp/xusrb1fix.sh.  Update: I have included this in the setup.sh script so there is no need to run this independently. 





    