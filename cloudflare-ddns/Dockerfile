ARG BUILD_FROM
FROM $BUILD_FROM

# This should stop s6-rc logging
ENV S6_LOGGING=0

# Install necessary packages
RUN apk add --no-cache \
    curl \
    jq

# Copy your script into the container
COPY ./dns-update.sh ./dns-update.sh
RUN chmod +x ./dns-update.sh

# Run the script
CMD ["./dns-update.sh"]
