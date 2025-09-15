#
# This source file is part of the Stanford Spezi open source project
#
# SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
#
# SPDX-License-Identifier: MIT
#

FROM alpine:3.19

LABEL org.opencontainers.image.authors="Philipp Zagar <zagar@stanford.edu>" \
      org.opencontainers.image.version="0.1" \
      org.opencontainers.image.title="stanfordspezi/avahi" \
      org.opencontainers.image.description="Avahi advertising services via mDNS" \
      org.opencontainers.image.url="https://ghcr.io/stanfordspezi/avahi" \
      org.opencontainers.image.source="https://github.com/StanfordBDHG/HealthGPT"

# Install Avahi daemon without dbus dependency
RUN apk --no-cache --no-progress add avahi

# Setup services
RUN rm -rf /etc/avahi/services
COPY services/ /etc/avahi/services

# Disable D-Bus in Avahi's configuration
RUN sed -i 's/.*enable-dbus=.*/enable-dbus=no/' /etc/avahi/avahi-daemon.conf

# Run Avahi daemon with non-root user, avoid daemonizing to keep container running
CMD ["avahi-daemon", "--no-chroot"]
