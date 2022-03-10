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

# Initialise the Seafile client, if not already initialised.
seafile_ini="$HOME/.ccnet/seafile.ini"
if [ ! -f "$seafile_ini" ]; then
    echo "Initializing Seafile client..."
    seaf-cli init -d ~/.seafile
    while [ ! -f "$seafile_ini" ]; do sleep 1; done
fi

# Start the Seafile daemon.
echo "Starting Seafile client..."
seaf-cli start
while [ ! -S "$HOME/.seafile/seafile-data/seafile.sock" ]; do sleep 1; done

# Synchronize the library, if not already synchronized.
if [ -z "$(seaf-cli status | grep -v ^\#)" ]; then
    echo "Synchronizing Seafile library..."
    # Set the disable_verify_certificate key to true only if the environment variable exists.
    [[ "$SEAF_SKIP_SSL_CERT" ]] && seaf-cli config -k disable_verify_certificate -v true

    # Set the upload/download limits
    [[ "$SEAF_UPLOAD_LIMIT" ]] && seaf-cli config -k upload_limit -v $SEAF_UPLOAD_LIMIT
    [[ "$SEAF_DOWNLOAD_LIMIT" ]] && seaf-cli config -k download_limit -v $SEAF_DOWNLOAD_LIMIT

    # Build the seaf-cli sync command.
    cmd="seaf-cli sync -u $SEAF_USERNAME -p $SEAF_PASSWORD -s $SEAF_SERVER_URL -l $SEAF_LIBRARY_UUID -d /library"
    [[ "$SEAF_2FA_SECRET" ]] && cmd+=" -a $(oathtool --base32 --totp $SEAF_2FA_SECRET)"
    [[ "$SEAF_LIBRARY_PASSWORD" ]] && cmd+=" -e $SEAF_LIBRARY_PASSWORD"

    # Run it.
    if ! eval $cmd; then echo "Failed to synchronize."; exit 1; fi
fi

# Continously print the log, infinitely.
while true; do
    tail -v -f ~/.ccnet/logs/seafile.log
    echo $?
done
