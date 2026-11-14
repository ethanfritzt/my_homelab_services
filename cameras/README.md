# Cameras → MediaMTX

Both **camone** and **camtwo** run the same script (`publish-stream.sh`) and publish into MediaMTX on the Docker VM (**192.168.1.167**).

## Per-camera settings

| Camera | Pi IP | STREAM_NAME | PORT |
|--------|-------|-------------|------|
| camone | 192.168.1.234 | camone | 5000 |
| camtwo | 192.168.1.171 | camtwo | 5001 |

Target hostname: **mediamtx.fritz3.org** (AdGuard resolves it to 192.168.1.167).

## Deploy

Copy the script to `/home/cam/publish-stream.sh` on each Pi, then set env via a systemd drop-in:

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

Then restart:

```bash
sudo systemctl restart camera-stream.service
```

Note: the Pis currently still run older per-cam copies with values hardcoded; migrating them is a separate step.

## MediaMTX paths

Configured in `mediamtx/mediamtx.yml` (unchanged in this rebuild pass):

| Path | Listen |
|------|--------|
| `zero` | UDP `:5000` |
| `one` | UDP `:5001` |

MediaMTX runs with `network_mode: host` on the Docker VM.

## Access policy

Publish is **open on the LAN by choice for now** (no auth on the publish path yet).
