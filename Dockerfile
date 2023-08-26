FROM ubuntu:22.04

ARG PATCH_VERSION="0.54.4"
ARG OPENGFX_VERSION="7.1"

RUN apt-get update && \
    apt-get install dos2unix dumb-init && \
    apt-get clean

ADD prepare.sh /tmp/prepare.sh
RUN dos2unix /tmp/prepare.sh
ADD cleanup.sh /tmp/cleanup.sh
RUN dos2unix /tmp/cleanup.sh
ADD buildconfig /tmp/buildconfig
RUN dos2unix /tmp/buildconfig
ADD --chown=1000:1000 openttd.sh /openttd.sh

RUN chmod +x /tmp/prepare.sh /tmp/cleanup.sh /openttd.sh

VOLUME /home/openttd/.local/share/openttd/

EXPOSE 3979/tcp
EXPOSE 3979/udp

STOPSIGNAL 3
# The following code section defines dumb-init as the entrypoint for the container, redirecting output to the next available container.
ENTRYPOINT [ "/usr/bin/dumb-init", "--rewrite", "15:3", "--rewrite", "9:3", "--" ]
# The server script running OpenTTD is then launched
CMD [ "/usr/bin/bash", "-c", "/tmp/prepare.sh && /tmp/cleanup.sh && exec openttd.sh" ]
