# openHAB IDE (Experimental)

A pre-configured Docker image to deploy a preconfigured instance of [Eclipse Theia](https://theia-ide.org) tailored for openHAB development & configuration, to install on your appliance.

## Features

- openHAB VS Code extension preinstalled and preconfigured; can open the console with no further configuration unless
- JavaScript development preconfigured (for JSR223)
- Opens a workspace (mapped to a Docker volume) containing your configuration automatically upon launch; no need to configure Samba shares
- Only expose the IDE over HTTPS by default on remote hosts, with token authentication

# Installation

There are no prebuilt images at the moment. Below are the instructions to build your own Docker image.

## Prerequisites

- Docker 19.03+
- 4 GB+ of free disk space for the image
- 2 GB+ RAM preferred (might work with 1 GB but no guarantees)

It's also possible to run outside Docker. Check the Theia prerequisites:
https://theia-ide.org/docs/composing_applications/
and follow the commands in the Dockerfile.

## Build the image

(TODO: docker-compose file)

### 1. Clone this repository

```sh
git clone https://github.com/ghys/openhab-ide
cd openhab-ide
```

### 2. Build the image

```sh
docker build -t openhab-ide .
```

The build process can take a while (~30 minutes on a PINE A64 with 2 GB RAM), be patient.
It should end with:
```
Successfully built 72a1c4ec78cd
Successfully tagged openhab-ide:latest
```

### 3. Run

Start a container with the newly built image (define $OPENHAB_CONF or replace it below with the location of your openHAB configuration folder e.g. `/etc/openhab` or `/opt/openhab/conf`):

```sh
docker run --rm -v $OPENHAB_CONF:/srv/openhab --net=host --name openhab-ide openhab-ide:latest /srv/openhab
```

(`--net=host` ensures your local openHAB instance on `localhost:8080` (by default) will be accessible.)

### 4. Retrieve the token to access the IDE

Run:

```sh
docker logs openhab-ide
```

and look in the logs for:

```text
...
access url: https://0.0.0.0:10443?token=9b2a11b5da6ff262b7a73d9676f63bc5
token: 9b2a11b5da6ff262b7a73d9676f63bc5
...
```

Copy the token.

_NOTE: The token is generated randomly by default and will change every time you run the container. You can add e.g. `-e token=mysecrettoken` in the `docker run` command above to define it yourself._

### 5. Open the IDE in a browser

**You will get a HTTPS error ("your connection isn't private" or similar) because the TLS certificate is self-signed and invalid. Ignore it the warning for now - click Advanced then Continue (or similar).**

Open `https://<host>:10443` and paste the token in the login page (or directly `https://<host>:10443?token=<token>`).

Verify that your configuration appears in the file explorer on the left, and that the list of items from your local openHAB instance appear.

There will be an error for the list of things, however, because you have to configure the authorization to the API by setting an API token.
Follow http://www.openhab.org/docs/configuration/apitokens.html to generate one, then in the IDE, open the File > Settings > Open Preferences menu, and in the openHAB section, click _Edit in settings.json_ below _Username_ and paste the token:

The settings should resemble the following:
```json
{
    "openhab.host": "localhost",
    "openhab.username": "oh.ide.CFWsJZ799oi3GcLSLd1C..."
}
```
Save the settings.json file, and go to the openHAB panel and click the Refresh buttons in the Things pane header. The list of Things should now appear.

TODO: improve this - allow setting the API token from Docker.

