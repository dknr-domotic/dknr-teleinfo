
# Use fix Node-red docker release
FROM nodered/node-red:5.0

# Switch to root user
USER root

# Update packages
RUN apk -U upgrade

# Install usermod
RUN apk add shadow

# Add node red user to dialout group to access to USB port
RUN usermod -aG dialout node-red

# Set environment variables
ENV DKNR_USERNAME=admin \
	DKNR_PASSWORD=admin \
	DKNR_SECRET=dkteleinfo \
    DKNR_REPOSITORY=https://github.com/dknr-domotic/dknr-teleinfo \
    NODE_RED_ENABLE_PROJECTS=true \
    DKNR_INFLUX_URL=http://dknr_teleinfo_influxdb:8086 \
    DKNR_INFLUX_TOKEN=dknr-teleinfo-influxdb-token \
    DKNR_INFLUX_ORG=dknr \
    DKNR_INFLUX_BUCKET=teleinfo \
	TZ=Europe/Paris

# Image label
LABEL org.opencontainers.image.authors="Jean-Christian Paul Denis" \
      org.opencontainers.image.source="https://github.com/dknr-domotic/dknr-teleinfo" \
      org.opencontainers.image.title="DKNR Teleinfo" \
      org.opencontainers.image.description="Teleinfo Parser with web UI and MQTT" \
      org.opencontainers.image.licenses="AGPL-3.0"

# Set system timezone
RUN echo "$TZ" > /etc/timezone

# Prepare Node-Red structure
RUN mkdir -p /data/projects/dknr-teleinfo

# Clone repository
RUN git clone ${DKNR_REPOSITORY} /data/projects/dknr-teleinfo

# Fix ownership
RUN chown -R node-red:node-red /data

# Switch to node-red user
USER node-red

# Set working diretory for container starting script
WORKDIR /data

# Add container starting script
ADD docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
