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

FROM debian:buster-slim

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
ARG PROJECT_URL
LABEL maintainer="jorge.ibanez@photonicsens.com.com" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="Seafile Docker client" \
    org.label-schema.description="Sync Seafile librairies within Docker containers." \
    org.label-schema.url=$PROJECT_URL \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url=$PROJECT_URL \
    org.label-schema.vendor="jorge.ibanez@photonicsens.com.com" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"

# Copy over the assets.
COPY docker-entrypoint.sh /entrypoint.sh
COPY docker-healthcheck.sh /healthcheck.sh

# Install seaf-cli and oathtool, prepare the user.
ENV DEBIAN_FRONTEND=noninteractive
ENV UNAME=seafuser UID=1000 GID=1000
RUN apt-get update && apt-get install wget -y
RUN wget https://linux-clients.seafile.com/seafile.asc -O /usr/share/keyrings/seafile-keyring.asc
RUN apt-get install -y gnupg && apt-get upgrade -y && \
    mkdir -p /etc/apt/sources.list.d/ && \
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/seafile-keyring.asc] https://linux-clients.seafile.com/seafile-deb/buster/ stable main' > /etc/apt/sources.list.d/seafile.list && \
    apt-get purge --yes gnupg && apt-get autoremove --yes && \
    apt-get update && apt-get install \
        --no-install-recommends \
        --yes \
            seafile-cli \
            oathtool && \
    apt-get clean && apt-get autoclean && \
    rm -rf \
        /var/log/fsck/*.log \
        /var/log/apt/*.log \
        /var/cache/debconf/*.dat-old \
        /var/lib/apt/lists/* \
    mkdir /library/ && \
    groupadd -g $GID -o $UNAME && \
    useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME && \
    mkdir /home/$UNAME/.seafile && \
    chown $UNAME:$GID /home/$UNAME/.seafile

COPY seafile-entrypoint.sh /home/seafuser/entrypoint.sh
RUN mv /healthcheck.sh /home/$UNAME/
RUN chmod +x /home/$UNAME/healthcheck.sh && \
    chown -R $UNAME:$GID /home/$UNAME/

ENTRYPOINT ["/bin/bash", "--"]
CMD ["/entrypoint.sh"]
HEALTHCHECK --start-period=1m CMD /home/$UNAME/healthcheck.sh
