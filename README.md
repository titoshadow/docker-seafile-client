[![](https://gitlab.com/%{project_path}/badges/%{default_branch}/pipeline.svg)](https://git.photonicsens.com/it/docker-seafile-client/-/commits/master)
[![](https://img.shields.io/docker/image-size/titoshadow/seafile-client/latest?label=Docker%20image%20size&color=%230778b8)](https://hub.docker.com/r/titoshadow/seafile-client)
[![](https://img.shields.io/docker/pulls/titoshadow/seafile-client?label=Docker%20pulls&color=%230778b8)](https://hub.docker.com/r/titoshadow/seafile-client)
[![](https://img.shields.io/badge/License-GPLv3-red.svg)](https://www.gnu.org/licenses/gpl-3.0)

**Share a Seafile library as a volume to other containers.**

**Based on [flowgunso/seafile-client](https://hub.docker.com/r/flowgunso/seafile-client) image, but updated Seafile client to 8.0.5.**

# Supported tags
[`latest`](seafile-client/Dockerfile)

# Informations
* Synchronize a single Seafile library, available at the path `/library/'.
* Password protected librairies are supported.
* Two factor authentication is supported.
* Upload and download speeds are configurable.
* SSL certificates are skippable.
<!-- -->


# Usage
## Required configuration
__SEAF_SERVER_URL__, __SEAF_USERNAME__, __SEAF_PASSWORD__, __SEAF_LIBRARY_UUID__
Provide your Seafile _server URL_, _username_, _password_ and _library UUID_ to synchronise your library at `/library`, then share it as a volume.

The `seaf-cli` is ran within the container as the user `seafuser`.

## Optional configurations
__SEAF_2FA_SECRET__
_Two factor authentication is supported but your secret key must be provided._ That key can be found on your Seafile web interface, only at the 2FA setup, when the QR code is shown. The secret key is embedded in the QR or available as a cookie.

__SEAF_LIBRARY_PASSWORD__
Password protected librairies can be sync provided with the _password_.

__SEAF_UPLOAD_LIMIT__, __SEAF_DOWNLOAD_LIMIT__
Upload and download speeds are configurable as _absolute bytes_.

__SEAF_SKIP_SSL_CERT__
Skip SSL certificates verifications. _Any string is considered true, omit the variable to set to false_. Enable this if you have synchronization failures regarding SSL certificates.

__UID__, __GID__
Override the _UID_ and _GID_ for volume read/write permissions.

# Examples
## As a Docker command
```
docker run \
    -e SEAF_SERVER_URL=https://seafile.example/ \
    -e SEAF_USERNAME=a_seafile_user \
    -e SEAF_PASSWORD=SoMePaSSWoRD \
    -e SEAF_LIBRARY_UUID=an-hexadecimal-library-uuid \
    -v path/to/shared/volume:/library \
    titoshadow/seafile-client:latest
```
## As a Docker Compose (recommended)
```yaml
services:

  seafile-client:
    image: titoshadow/seafile-client:latest
    volumes:
      - shared_volume:/library
    environment:
      SEAF_SERVER_URL: "https://seafile.example/"
      SEAF_USERNAME: "a_seafile_user"
      SEAF_PASSWORD: "SoMePaSSWoRD"
      SEAF_LIBRARY_UUID: "an-hexadecimal-library-uuid"

volumes:
  shared_volume:
```
## With all optional configurations
```yaml
services:

  seafile-client:
    image: titoshadow/seafile-client:latest
    volumes:
      - shared_volume:/library
    environment:
      SEAF_SERVER_URL: "https://seafile.example/"
      SEAF_USERNAME: "a_seafile_user"
      SEAF_PASSWORD: "SoMePaSSWoRD"
      SEAF_LIBRARY_UUID: "an-hexadecimal-library-uuid"
      SEAF_2FA_SECRET: "JBSWY3DPEHPK3PXPIXDAUMXEDOXIUCDXWC32CS"
      SEAF_LIBRARY_PASSWORD: "LiBRaRyPaSSWoRD"
      SEAF_UPLOAD_LIMIT: "1000000"
      SEAF_DOWNLOAD_LIMIT: "1000000"
      SEAF_SKIP_SSL_CERT: "true"
      UID: "1000"
      GID: "1000"

volumes:
  shared_volume:
```
