# asterisk

Docker images with Asterisk for automated voice notifications.

![Docker CI](https://github.com/rhierlmeier/asterisk/actions/workflows/docker-ci.yml/badge.status)

## Description

This project provides a Dockerized Asterisk instance pre-configured to send automated voice notifications (fault reports). It includes scripts to trigger calls and a set of audio files for playing back fault numbers.

## Features

- **Automated Voice Notifications**: Play custom sounds based on a "fault number" (`stoerNr`).
- **Dynamic Configuration**: `sip.conf` is generated at runtime via environment variables.
- **Easy Triggering**: Simple shell script to initiate notification calls.

## Prerequisites

- Docker installed on your host.
- A SIP provider or a local PBX (like a FritzBox) to handle outgoing calls.

## Environment Variables

The container requires the following environment variables to configure the SIP connection:

| Variable | Description | Example |
| :--- | :--- | :--- |
| `SIP_HOST` | SIP server address | `fritz.box` |
| `SIP_EXTERN_HOST` | External IP or hostname for SIP NAT | `your-external-ip.com` |
| `SIP_LOCAL_NET` | Local network range | `192.168.178.0/255.255.255.0` |
| `SIP_USERNAME` | SIP authentication username | `asterisk_user` |
| `SIP_PASSWORD` | SIP authentication password | `your_secure_password` |
| `SIP_PORT` | (Optional) SIP UDP port (Default: `5060`) | `5060` |
| `SIP_FROM_USER` | (Optional) From-User in SIP header (Default: `$SIP_USERNAME`) | `asterisk_user` |

## Getting Started

### Building the Image

```bash
docker build -t asterisk-notifier .
```

### Running the Container

```bash
docker run -d \
  --name asterisk-notifier \
  -e SIP_HOST=fritz.box \
  -e SIP_EXTERN_HOST=yourhost.example.com \
  -e SIP_LOCAL_NET=192.168.1.0/24 \
  -e SIP_USERNAME=myuser \
  -e SIP_PASSWORD=mypassword \
  asterisk-notifier
```

## Usage

### Triggering a Notification

To trigger a notification for a specific fault number (e.g., fault #5), execute the `create_stoerung.sh` script inside the running container:

```bash
docker exec asterisk-notifier /app/create_stoerung.sh 5
```

This will:
1. Create a call file in `/var/spool/asterisk/outgoing/`.
2. Asterisk will dial the numbers defined in the notification chain.
3. Once answered, it will play the audio files: `heizung.ulaw`, `stoerung_5.ulaw`, and `wiederhole.ulaw`.

## Configuration

### SIP Configuration

The container generates `/etc/asterisk/sip.conf` on startup if it doesn't already exist. It uses the `[fritzbox]` peer name by default for outgoing calls.

### Notification Chain

The notification chain is defined in `asterisk/extensions.conf` under the `[heizung_melde_kette]` context. You may want to customize the phone numbers dialed in this section.

### Sounds

Audio files are located in `/opt/asterisk/sounds/`. Fault-specific sounds follow the naming convention `stoerung_<number>.ulaw`.
