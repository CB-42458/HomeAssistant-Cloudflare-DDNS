ARG BUILD_FROM
FROM $BUILD_FROM

# This should hoppefully prevent logging from the s6-overlay
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
