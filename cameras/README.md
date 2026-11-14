# Cameras → MediaMTX

Both **camone** and **camtwo** run the same script (`publish-stream.sh`) and publish into MediaMTX on the Docker VM (**192.168.1.167**, VM 100 — not a Pi 5).

## Hardware

| Component | Spec |
|-----------|------|
| Board | Raspberry Pi Zero W (or WH) |
| Camera | Arducam OV5647 (CSI) |
| Storage | MicroSD (8GB+, Class 10 / A1 recommended) |
| Power | 5V 2A USB adapter |
| Network | 2.4 GHz Wi-Fi (strong signal) |

Current publish settings: **640×480 @ 15 fps**, UDP MPEG-TS, **no publish auth**. MediaMTX runs in Docker (`network_mode: host`) on the Docker VM and serves RTSP/WebRTC/HLS to viewers.

## Per-camera settings

| Camera | Pi IP | STREAM_NAME | PORT |
|--------|-------|-------------|------|
| camone | 192.168.1.234 | camone | 5000 |
| camtwo | 192.168.1.171 | camtwo | 5001 |

Target hostname: **mediamtx.fritz3.org** (AdGuard resolves it to 192.168.1.167).

## Pi node setup

### 1. OS and packages

Flash **Raspberry Pi OS Lite** (Bookworm or newer). On first boot, set hostname, Wi-Fi, and enable SSH as needed.

```bash
sudo apt update
sudo apt install -y rpicam-apps
```

### 2. Camera overlay (OV5647)

Arducam OV5647 modules often need an explicit overlay (auto-detect alone is unreliable on Zero W). Edit `/boot/firmware/config.txt` (or `/boot/config.txt` on older images):

```ini
camera_auto_detect=0
dtoverlay=ov5647
```

Reboot, then smoke-test:

```bash
rpicam-hello -t 2000
```

### 3. `cam` user and files

```bash
sudo useradd -m -s /bin/bash cam
# ensure cam can access the camera (video group is typical)
sudo usermod -aG video cam

sudo install -o cam -g cam -m 0755 publish-stream.sh /home/cam/publish-stream.sh
sudo cp camera-stream.service /etc/systemd/system/camera-stream.service
sudo systemctl daemon-reload
```

### 4. Drop-in env and enable

```bash
sudo systemctl edit camera-stream.service
```

camone:

```ini
[Service]
Environment=STREAM_NAME=camone
Environment=PORT=5000
```

camtwo:

```ini
[Service]
Environment=STREAM_NAME=camtwo
Environment=PORT=5001
```

Then:

```bash
sudo systemctl enable --now camera-stream.service
sudo systemctl status camera-stream.service
```

Optional: `Environment=SERVER_IP=mediamtx.fritz3.org` (script default if unset).

Note: the Pis currently still run older per-cam copies with values hardcoded; migrating them is a separate step.

## Deploy (script / drop-in refresh)

Copy the script to `/home/cam/publish-stream.sh` on each Pi, then set env via a systemd drop-in:

```bash
sudo systemctl edit camera-stream.service
```

Then restart:

```bash
sudo systemctl restart camera-stream.service
```

## SD card cloning for a new camera

1. Image a working camera SD card onto a new card and boot the new Pi.
2. Change hostname (`sudo raspi-config` or edit `/etc/hostname` + `/etc/hosts`).
3. Set a new STREAM_NAME / PORT drop-in (`sudo systemctl edit camera-stream.service`) — do not reuse another cam’s PORT.
4. Add a matching MediaMTX UDP path on the Docker VM (see [MediaMTX paths](#mediamtx-paths) and `mediamtx/mediamtx.yml`).
5. Restart: `sudo systemctl restart camera-stream.service`.
6. Confirm AdGuard / DHCP reservation for the new Pi IP if needed.

## MediaMTX paths

Configured in `mediamtx/mediamtx.yml` (on the Docker VM; see also `mediamtx/docker-compose.yml`):

| Path | Listen |
|------|--------|
| `zero` | UDP `:5000` |
| `one` | UDP `:5001` |

MediaMTX runs with `network_mode: host` on the Docker VM. To add another camera, add a new `paths:` entry with `source: udp://:<port>` and `sourceProtocol: udp`, then recreate/restart the container.

## Access policy

Publish is **open on the LAN by choice for now** (no auth on the publish path yet).

## Troubleshooting

**Service / logs**

```bash
sudo systemctl status camera-stream.service
journalctl -u camera-stream -f
```

**Camera hardware**

```bash
rpicam-hello -t 2000
# If it fails: reseat CSI cable, confirm dtoverlay=ov5647, reboot
```

**Network / UDP**

```bash
ping mediamtx.fritz3.org   # should be 192.168.1.167
# Confirm PORT matches the MediaMTX path listen port
# On the Docker VM: docker compose -f mediamtx/docker-compose.yml ps
```

**Common failures**

| Symptom | Check |
|---------|--------|
| `STREAM_NAME: set STREAM_NAME` | Drop-in missing; `systemctl cat camera-stream` |
| Camera not detected | Overlay / CSI / `rpicam-hello` |
| Stream never appears in MediaMTX | Wrong PORT, firewall, or MediaMTX path not listening |
| High CPU / dropouts | Stay at 640×480 @ 15 fps; improve Wi-Fi RSSI |
