#!/bin/bash

# Docker Seafile client, help you mount a Seafile library as a volume.
# Copyright (C) 2022, jorge.ibanez@photonicsens.com
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

function fail_with_message {
    echo "$1"
    echo "Exiting container."
    exit 1
}

# Check mandatory Seafile configuration have been properly set.
[[ -z "$SEAF_SERVER_URL" ]] && fail_with_message "The \$SEAF_SERVER_URL is not defined."
[[ -z "$SEAF_USERNAME" ]] && fail_with_message "The \$SEAF_USERNAME is not defined."
[[ -z "$SEAF_PASSWORD" ]] && fail_with_message "The \$SEAF_PASSWORD is not defined."
[[ -z "$SEAF_LIBRARY_UUID" ]] && fail_with_message "The \$SEAF_LIBRARY_UUID is not defined."
[[ -n "$SEAF_UPLOAD_LIMIT" && $SEAF_UPLOAD_LIMIT =~ ^[0-9]+$ && "$SEAF_UPLOAD_LIMIT" -gt 0 ]] && \
    fail_with_message "The \$SEAF_UPLOAD_LIMIT is not an integer greater than 0."
[[ -n "$SEAF_DOWNLOAD_LIMIT" && $SEAF_DOWNLOAD_LIMIT =~ ^[0-9]+$ && "$SEAF_DOWNLOAD_LIMIT" -gt 0 ]] && \
    fail_with_message "The \$SEAF_DOWNLOAD_LIMIT is not an integer greater than 0."

# Update the user ID, if the $UID changed.
# TODO: What if the $UID already exists ?
[[ "$UID" != "1000" ]] && usermod -u $UID $UNAME

# Change the group, if the $GID changed.
if [ "$GID" != "1000" ]; then
    getent group | grep ":$GID:" >/dev/null
    if [ $? -eq 0 ]; then
        usermod -g $GID -G 1000 $UNAME
    else
        groupmod -g $GID $UNAME
    fi
fi

# Set the files ownership.
chown $UID.$GID /home/seafuser/healthcheck.sh
chown $UID.$GID /home/seafuser/entrypoint.sh
chown $UID.$GID -R /library

# Run the Seafile client as the container user.
su - $UNAME << EO
    export SEAF_SERVER_URL=$SEAF_SERVER_URL
    export SEAF_USERNAME=$SEAF_USERNAME
    export SEAF_PASSWORD=$SEAF_PASSWORD
    export SEAF_LIBRARY_UUID=$SEAF_LIBRARY_UUID
    [[ "$SEAF_SKIP_SSL_CERT" ]] && export SEAF_SKIP_SSL_CERT=$SEAF_SKIP_SSL_CERT
    [[ "$SEAF_UPLOAD_LIMIT" ]] && export SEAF_UPLOAD_LIMIT=$SEAF_UPLOAD_LIMIT
    [[ "$SEAF_DOWNLOAD_LIMIT" ]] && export SEAF_DOWNLOAD_LIMIT=$SEAF_DOWNLOAD_LIMIT
    [[ "$SEAF_2FA_SECRET" ]] && export SEAF_2FA_SECRET=$SEAF_2FA_SECRET
    [[ "$SEAF_LIBRARY_PASSWORD" ]] && export SEAF_LIBRARY_PASSWORD=$SEAF_LIBRARY_PASSWORD
    /bin/bash /home/seafuser/entrypoint.sh
EO
