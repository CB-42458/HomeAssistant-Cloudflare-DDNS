# DNS-Updater Add-on for Home Assistant

This add-on for Home Assistant allows you to automatically update your DNS records with your public IP address. It's especially useful if your ISP assigns dynamic IP addresses and you want to maintain access to your Home Assistant instance from outside your home network.

## Features

- Automatically fetches your public IP address
- Updates your DNS records with the fetched IP address
- Supports multiple domains

## Configuration

You can edit configuration options for the add-on in the Home Assistant UI. The following options are available:

## Usage

The add-on can be run manually, or it can be set up to run automatically at regular intervals using Home Assistant's automation features.

## Logs

The add-on provides logs to help you track the DNS update process. Each log entry is timestamped and provides information about the update process.

## Installation

To install the add-on, follow the standard add-on installation procedure in Home Assistant.

## Support

If you encounter any issues or have any questions about this add-on, please open an issue on the GitHub repository.

## Attributions

- DNS icon by Icons8: https://icons8.com/icon/114654/dns
- shell script based on https://github.com/Steve8291/dns-update-cloudflare