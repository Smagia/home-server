# Local Home Server Setup

This repository contains a Docker Compose configuration for setting up a local home server with multiple services, including Portainer, File Browser, Transmission, Jellyfin, Calibre Web, Syncthing, and Immich.

## Services

### Portainer
- **Description**: `A web-based Docker management interface.`
- **Image**: `portainer/portainer`
- **Port**: `8088`
### File Browser
- **Description**: `A web interface to manage files on your server.`
- **Image**: `filebrowser/filebrowser`
- **Port**: `8089`
### Transmission
- **Description**: `A BitTorrent client for downloading and seeding torrents.`
- **Image**: `linuxserver/transmission`
- **Port**: `8090`
### Jellyfin
- **Description**: `A media server for streaming and managing your media collection.`
- **Image**: `jellyfin/jellyfin`
- **Port**: `8091`
### Calibre Web
- **Description**: `A web application for managing and accessing your eBook library.`
- **Image**: `lscr.io/linuxserver/calibre-web:latest`
- **Port**: `8092`
### Syncthing
- **Description**: `A continuous file synchronization tool for keeping files in sync across devices.`
- **Image**: `syncthing/syncthing`
- **Port**: `8093`
### Immich Server
- **Description**: `A self-hosted photo and video backup solution.`
- **Image**: `ghcr.io/immich-app/immich-server:${IMMICH_VERSION:-release}`
- **Port**: `8094`

## Usage

1. Clone the repository.
2. Create a `.env` file with the necessary environment variables.
3. Set the `BASE_DIR`, `UPLOAD_LOCATION`, `DB_PASSWORD` in your environment.
4. Do not change `DB_USERNAME`, `DB_DATABASE_NAME`, and `DB_DATA_LOCATION`, see Immich documentation
5. Run `docker-compose up -d` to start the services.

## Notes

- Ensure you have Docker and Docker Compose installed.
- Customize the environment variables and paths as needed.
- This setup is intended for a local home server and not for production use.

Feel free to open issues or contribute to the project. Enjoy your home server setup!
