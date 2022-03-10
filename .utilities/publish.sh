# !/bin/bash

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

apk add curl

SCRIPT_DIRECTORY=$(dirname ${BASH_SOURCE[0]})
source $SCRIPT_DIRECTORY/utilities.sh
load_images_artifacts

# Generate version tags.
tags=("latest")
for version_component in $(echo $CI_COMMIT_TAG | tr "." "\n"); do
    tag+="$version_component"
    tags+=("$tag")
    tag+="."
done

# Tag then push the Docker Hub registry.
echo $CI_REGISTRY_BOT_PASSWORD | docker login --password-stdin --username $CI_REGISTRY_BOT_USERNAME
for tag in "${tags[@]}"; do
    docker tag $CI_PROJECT_NAME:build $CI_REGISTRY_IMAGE:$tag
    docker push $CI_REGISTRY_IMAGE:$tag
done
