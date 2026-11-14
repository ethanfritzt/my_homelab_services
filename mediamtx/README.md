# MediaMTX

MediaMTX receives UDP MPEG-TS from the camera Pis and serves it to viewers (Home Assistant, browsers, VLC). It runs as a Docker container on the Docker VM (**VM 100**, **192.168.1.167**), not on a Pi 5.

Camera node setup lives in [cameras/README.md](../cameras/README.md).

## Runtime

| Item | Value |
|------|--------|
| Host | Docker VM `docker` · VM 100 · 192.168.1.167 |
| Compose | [`docker-compose.yml`](docker-compose.yml) |
| Config | [`mediamtx.yml`](mediamtx.yml) |
| Network | `network_mode: host` |
| Image | `bluenviron/mediamtx` pinned by digest in `docker-compose.yml` |
| Container | `mediamtx-rtsp` |

Deploy path on the VM: `/home/ethan/my_homelab_services/mediamtx`.

```bash
cd /home/ethan/my_homelab_services/mediamtx
docker compose up -d
```

The only customization over MediaMTX defaults is the `paths:` block in `mediamtx.yml`.

## Paths (UDP ingest)

Cameras publish UDP MPEG-TS to the Docker VM. MediaMTX listens per path:

| Path | Camera | Listen |
|------|--------|--------|
| `zero` | camone | UDP `:5000` |
| `one` | camtwo | UDP `:5001` |

`STREAM_NAME` on the Pi (`camone` / `camtwo`) is for the node drop-in; the MediaMTX path name is `zero` / `one`. Matching is by **UDP port**.

## Consumer protocols

Enabled in `mediamtx.yml` and used here:

| Protocol | Port | Enabled |
|----------|------|---------|
| RTSP | 8554 | yes (`rtsp: yes`) |
| HLS | 8888 | yes (`hls: yes`) |
| WebRTC | 8889 | yes (`webrtc: yes`) |

### Home Assistant

HA reads the RTSP URLs (no credentials; publish/read are open on the LAN for now):

- `rtsp://192.168.1.167:8554/zero`
- `rtsp://192.168.1.167:8554/one`

### Other viewers

| Protocol | URL |
|----------|-----|
| RTSP | `rtsp://192.168.1.167:8554/<path>` |
| WebRTC | `http://192.168.1.167:8889/<path>` |
| HLS | `http://192.168.1.167:8888/<path>` |

Replace `<path>` with `zero` or `one`.

## Add a camera path

Adapted from the old `add-camera-path.sh` helper (native Pi 5 / auth-per-path). Today MediaMTX is Docker + UDP ingest with no per-path publish auth — do it manually:

1. On the Docker VM, edit `mediamtx/mediamtx.yml`. Under `paths:`, add an entry before `all_others:`:

   ```yaml
   two:
     source: udp://:5002
     sourceProtocol: udp
   ```

   Pick the next free UDP port (`5000`, `5001`, then `5002`, …). Path name can be `two`, `three`, or a short label — it becomes the RTSP path segment.

2. Restart the container:

   ```bash
   cd /home/ethan/my_homelab_services/mediamtx
   docker compose up -d --force-recreate
   ```

3. On the new Pi, set the systemd drop-in so `PORT` matches the listen port and `STREAM_NAME` is unique. See [cameras/README.md](../cameras/README.md) (drop-in env, SD cloning).

4. Confirm ingest and consumers:

   - MediaMTX logs show the path ready
   - RTSP: `rtsp://192.168.1.167:8554/<path>`

## Status checks

Adapted from the old `check-mediamtx-status.sh` (systemd + Control API). API is **off** (`api: no`); use Docker instead.

On the Docker VM, from `mediamtx/`:

```bash
docker compose ps
docker logs mediamtx-rtsp --tail 50
docker logs -f mediamtx-rtsp
```

Healthy: container `Up`, logs show listeners on the UDP ingest ports and RTSP/HLS/WebRTC addresses. If a camera is publishing, you should see traffic / path activity for `zero` or `one`.

Configured paths are the keys under `paths:` in `mediamtx.yml` (ignore `all_others`).

## Intentionally not ported

- **`setup-mediamtx-server.sh`** — obsolete Pi 5 native build (compile MediaMTX + systemd). Replaced by this Docker Compose stack.
- **Per-path publish/read passwords** — old scripts assumed auth; current `mediamtx.yml` leaves LAN access open (same policy as [cameras/README.md](../cameras/README.md)).
