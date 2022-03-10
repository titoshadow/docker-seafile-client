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

apk add curl jq

# Load utilities functions.
SCRIPT_DIRECTORY=$(dirname ${BASH_SOURCE[0]})
source $SCRIPT_DIRECTORY/utilities.sh

# Restrict the job to the right schedule.
if [[ "$SCHEDULE_ID" != "$PACKAGE_UPDATE_NOTIFICATION_SCHEDULE_ID" ]]; then
    exit_with_message_and_code "Schedule ID did not match." 0
fi

# Fetch the issue state if the ISSUE_ID variable is set,
# if that state is closed remove the ISSUE_ID variable and continue the job, otherwise exit the job.
if [[ -n "$ISSUE_ID" ]]; then
    issue_state="$(curl -H \"PRIVATE-TOKEN: $REPORTER_BOT_ACCESS_TOKEN\" \
        https://gitlab.com/api/v4/projects/$CI_PROJECT_ID/issue/$ISSUE_ID | jq .state)"
    if [[ "$issue_state" == "closed" ]]; then
        echo "An issue exist, but is closed. Removing ISSUE_ID schedule variable..."
        curl -X DELETE \
            -H "PRIVATE-TOKEN: $REPORTER_BOT_ACCESS_TOKEN" \
            https://gitlab.com/api/v4/projects/$CI_PROJECT_ID/pipeline_schedules/$SCHEDULE_ID/variables/$ISSUE_ID
    else
        exit_with_message_and_code "An issue already exists, it is not closed yet." 0
    fi
fi

# Get the installed and candidate versions of the seafile-cli package from the latest Docker image.
docker pull $CI_REGISTRY_IMAGE:latest
candidate_version=$(docker run --rm --entrypoint="" $CI_REGISTRY_IMAGE:latest \
    bash -c "\
        apt-get -qq update;\
        apt-cache policy seafile-cli | grep 'Candidate:' | awk '{print \$2}'")
installed_version=$(docker run --rm --entrypoint="" $CI_REGISTRY_IMAGE:latest \
    bash -c "\
        apt-get -qq update;\
        apt-cache policy seafile-cli | grep 'Installed:' | awk '{print \$2}'")

# Create an issue if a new version was released.
if [[ "$installed_version" == "$candidate_version" ]]; then
    exit_with_message_and_code "No new version of the seafile-cli package have been released." 0
else
    echo "A new version of the seafile-cli package have been released. Creating a new issue..."
    data=$(jq -n \
        --arg title "seafile-cli v${candidate_version} was released" \
        --arg description "Check for new feature, breaking changes or anything worth updating to update the Docker image." \
        --arg labels "enhancement" \
        '{title: $title, description: $description, labels: [$labels]}')
    curl -X POST \
        -H "PRIVATE-TOKEN: $REPORTER_BOT_ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$data"
        https://gitlab.com/api/v4/projects/$CI_PROJECT_ID/issues
fi
