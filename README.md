# VistAJS
This is a javascript version of VistA RPC broker from [eHMP](https://github.com/KRMAssociatesInc/eHMP).  It can be used to make RPC calls against VistA. 


After setting up codespaces (outlined below), try the following.  You can run this from a terminal in the codespace if you are on a browser....OR from your workstation if you are running the codespace in VS Code on your workstation. If you are running the codespace from your workstation the ports are mapped to localhost automatically. 

```
node index.js
```

- Please remember you need a valid user with a valid Access / Verify Code.  Depending on the version of VistA you are using that will vary. 

# Codespace version of VistA.

This repository has an implementation that will run the FOIA version of VistA for testing VistAJS, using a [.devcontainer](/.devcontainer) configuration. See the /vista directory in the repo for the underlying VistA/IRIS config files.

  - Open this repo in a GitHub Codespace (or "Reopen in Container" locally with Docker + the Dev Containers extension). The devcontainer will build the InterSystems IRIS Community image and install Node.js automatically.
  - Before the container is created, `.devcontainer/initialize.sh` runs on the host: it downloads the FOIA version of VistA (the compacted 2022_09_07 release), extracts `IRIS.DAT`, and generates `merge.cpf`. This runs first so the database is already in place before IRIS starts.
  - The container itself does **not** override the base IRIS image's own entrypoint (`devcontainer.json` sets `"overrideCommand": false`) - it handles CPF merging, database mounting, and starting IRIS the same way it always has (matching the original `docker-compose.yml`'s `command: --check-caps false -a /xinetd.sh`). Our Dockerfile just points its `-a` action at [.devcontainer/entrypoint.sh](/.devcontainer/entrypoint.sh) (installed as `/opt/vistajs/post-init.sh`), which loads XUSRB1/SMEINT and creates a generic Provider user on first run only, then starts `xinetd`. The routine used to create the user is from https://github.com/WorldVistA/VistA-FHIR-Data-Loader/blob/master/src/SYNINIT.m

  - Unfortunately the VA has made the FOIA Version of VistA too large for the community version of Intersystems IRIS. I have compacted the latest version and this repo uses that by default (2022_09_07).  But you can update the URL/ZIP variables in [initialize.sh](/.devcontainer/initialize.sh) to use any version of VistA you would like, or a licensed version of IRIS if you have one.

   - ** Update - I have been talking to the VA staff that releases FOIA version about defragging / compacting / truncating it before posting.

   - ** Update - THe latest version of FOIA VistA is now < 10gig.

   - ** Update - Codespaces changed the way they handle Docker containers in 2025, which broke the old docker-compose based setup in this repo. This has been replaced with a `.devcontainer` configuration that works with the current Codespaces container support.

  - To reset VistA back to the beginning, delete the `vista/data` directory and rebuild the container (or delete the Codespace and create a new one). This removes everything, including the downloaded database.

  # Accessing Management portal of Intersystems

  Once you have intersystems running, to access the management portal, check the ports assigned.

  - Find the url for the 52773 port.
  - Right mouse click and select open in browser.  Add /csp/sys/UtilHome.csp to the url. (see https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GSA_using_portal#GSA_using_portal_start for more info)
  - log in with _SYSTEM and password SYS

  # Logging into VistA

  The devcontainer sets up shell aliases automatically on first run. Open a new terminal (or run `source ~/.bashrc`) to pick them up.


  - You can log into VistA with the following from the shell prompt.

      ``
        vista
      ``
  
  # Shortcuts

  - You can get to the Mumps direct prompt with the following from the shell prompt. 

      ``
        prog
      ``
  - You can log into the VISTA namespace directly with the following from the shell prompt.

      ``
        vista
      ``
  - you can get an interactive shell as the IRIS owner by typing the following from the shell prompt.

      ``
        irisowner
      ``

# Xinetd

The VistA setup in this repo uses Xinted for RPC Broker and VistaLink.  There is one change necessary if you switch from the community version to a licnesed version of Iris.  irissession is located in a different location for each.  Look for more info in the stg_rpc and stg_vlk files in the vista directory.

# FOIA and Access / Verify Code

 - The JS library in this repo will not work with the FOIA version of Vista.  It has to do with the FOIA version not having the VA encryption. More information can be found [here](https://groups.google.com/g/hardhats/c/egI15djGp5A/m/ZuWf785pQy0J).  I have included a copy from this thread in this repo [xusrb1.xml](/vista/xusrb1.xml). This fix is applied automatically by [entrypoint.sh](/.devcontainer/entrypoint.sh) on first container start, so there is no need to run it independently.


# BSE Tokin Authentication to VistA 
 - BSE token authentication support has been added to the VistAJS library, also called the "visitor pattern".  This dempnstrates how to use a VA issued service account to authenticate to VistA and execute RPC calls. look at [bseLogin.js](/bseLogin.js) for more information.  The VistaJSLibray has also been updated to support the 'global' RPC parameter type. 

# Troubleshooting the Codespace/devcontainer VistA setup

  - **"Not a valid ACCESS CODE/VERIFY CODE pair" even though the creation log shows the user was created**: Re-run the init scripts manually to fix it (as `irisowner`, since the container's main process now runs as `irisowner`, not `root`):
    ```
    rm /workspace/vista/data/.vistajs-initialized
    su irisowner -c "iris session IRIS < /opt/vistajs/xusrb1fix.script"
    su irisowner -c "iris session IRIS < /opt/vistajs/CreateUser.script"
    su irisowner -c "iris stop IRIS quietly"
    su irisowner -c "iris start IRIS"
    ```

  - **`iris` command doesn't behave as expected / runs `su irisowner` instead**: Check `alias` output - an old `.bashrc` from a previous container run may have a stale `alias iris=...`. Run `unalias iris` or open a new terminal.

  - **RPC connection is refused (`ECONNREFUSED`)**: Confirm `xinetd` is actually running and bound to the RPC/VistaLink ports:
    ```
    ps aux | grep xinetd
    ss -tlnp | grep -E '19301|18301'
    ```
    If it isn't listed, check the container logs for errors from `/opt/vistajs/post-init.sh` or `xinetd`'s own config parsing.

  - **Devcontainer changes don't seem to apply after "Rebuild Container"**: The devcontainer definition used for a rebuild comes from the git checkout *inside* the Codespace, not directly from GitHub. Run `git pull` inside the Codespace first, then rebuild.

  - **IRIS.DAT missing or the container starts before it finishes downloading**: The download now happens in `.devcontainer/initialize.sh`, which runs on the host *before* the container is created. Check that step's output in the Codespace creation log if the database seems empty.

# SAML Login to VistA (VA PIV)

 - [samlLogin.js](/samlLogin.js) tests VA PIV SAML authentication to VistA. It depends on a VA SAML token getter service that runs locally on your desktop and is not shared externally in this repo, so this script will not work out of the box for other users.



    
