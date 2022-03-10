#!/bin/bash

# Docker Seafile client, help you mount a Seafile library as a volume.
# Copyright (C) 2019-2020, flow.gunso@gmail.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Based upon https://gist.github.com/jlhawn/8f218e7c0b14c941c41f
# and https://github.com/moikot/golang-dep/blob/master/.travis/push.sh

# This action can only be done with the actual owner of the repository,
# unless you can extend the collaborator's permissions but as far as I know, you can't.

# Install required system packages.
apk add curl jq

# Get a token from hub.docker.com with the owner credentials.
token=$(curl -s \
        -X POST \
        -H "Content-Type: application/json" \
        -d '{"username": "'"$CI_REGISTRY_OWNER_USERNAME"'", "password": "'"$CI_REGISTRY_OWNER_PASSWORD"'"}' \
        https://hub.docker.com/v2/users/login/ | jq -r .token)

# Generate a JSON with the README.md as the full_description.
json=$(jq -n \
    --arg readme "$(<README.md)" \
    '{"full_description": $readme}')

# Update the Docker Hub repository's full_description.
curl -s -L \
    -X PATCH \
    -d "$json" \
    -H "Content-Type: application/json" \
    -H "Authorization: JWT $token" \
    https://cloud.docker.com/v2/repositories/$CI_REGISTRY_IMAGE/