# Restore / rebuild outline (Proxmox era)

High-level steps to recreate the lab after a rebuild. Marked TODOs are not documented yet.

## Outline

1. Recreate **VM 100** (`docker`) — Debian 13 at 192.168.1.167.
2. Install **Docker Engine** and **Docker Compose** on the VM.
3. Clone this repo to `/home/ethan/my_homelab_services`.
4. Restore per-service `.env` files and data volumes/directories (Immich library/Postgres paths, Navidrome music/cache, Caddy data volume, etc.).
5. `docker compose up -d` in each service directory under `/home/ethan/my_homelab_services/<svc>`.
6. Bring **Caddy** up **last** (TLS + reverse proxies after backends).
7. Recreate / restore **AdGuard LXC 102** (`adguard` at 192.168.1.53) with Quad9 DoH, filtering on, blocklists off, and `*.fritz3.org` → `192.168.1.167`.
8. Import **HAOS** VM 101 (`home-assistant`) as needed (see [home-assistant.md](home-assistant.md)).

## Backups

TODO: vzdump / Proxmox backup restore procedure (backups are not set up yet).

TODO: Document exact data-path restore commands for Immich, Navidrome, Caddy volumes, and camera publish host files.
