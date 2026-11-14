# Cameras → MediaMTX

Cameras **camone** and **camtwo** publish into MediaMTX on the Docker VM (**192.168.1.167**).

## Publish (not in this repo)

| Piece | Detail |
|-------|--------|
| Script | `/home/cam/publish-stream.sh` |
| Service | `camera-stream.service` |
| Target | mediamtx.fritz3.org (resolves to 192.168.1.167 via AdGuard) |

Those host files live outside this repository.

## MediaMTX paths

Configured in `mediamtx/mediamtx.yml` (unchanged in this rebuild pass):

| Path | Listen |
|------|--------|
| `zero` | UDP `:5000` |
| `one` | UDP `:5001` |

MediaMTX runs with `network_mode: host` on the Docker VM.

## Access policy

Publish is **open on the LAN by choice for now** (no auth on the publish path yet).
