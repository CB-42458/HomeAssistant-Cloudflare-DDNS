ARG BUILD_FROM
FROM $BUILD_FROM

# Install necessary packages
RUN apk add --no-cache \
    curl \
    jq

# Copy your script into the container
COPY ./dns-update.sh ./dns-update.sh
RUN chmod +x ./dns-update.sh

# Run the script
CMD ["./dns-update.sh"]
