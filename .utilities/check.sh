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

# Check the CI pipeline sources.
if ! [[ "$CI_PIPELINE_SOURCE" == "push" ]]; then
    echo "CI pipelines are only allowed from push."
    exit 1
fi

# Check the tag is properly defined on job other than update_docker_hub_full_description job,
# on pushed CI pipelines.
if [[ "$CI_PIPELINE_SOURCE" == "push" ]]; then
    if ! [[ "$CI_JOB_NAME" == "update_docker_hub_full_description" ]]; then 
        if [[ -z "$CI_COMMIT_TAG" && "$CI_COMMIT_TAG" =~ ^[0-9]+[.][0-9]+[.][0-9]+$ ]]; then
            echo "The \$CI_COMMIT_TAG $CI_COMMIT_TAG does not match the MAJOR.Minor.revision layout."
            exit 1
        fi
    fi
fi
