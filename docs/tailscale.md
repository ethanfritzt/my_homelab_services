# Tailscale

## Current setup

Proxmox host `pve` (192.168.1.165) runs Tailscale as a **subnet router** for `192.168.1.0/24`. Remote access to LAN hosts goes through Tailscale instead of the old VPN/DDNS path.

## Replaces

| Retired | Replacement |
|---------|-------------|
| PiVPN on the Pi 3 | Tailscale subnet router on Proxmox |
| DuckDNS | Not needed for this access path |

## Planned: Grok Bot ACL

Planned (not yet configured):

- Tag: `tag:grokbot`
- ACL: allow **tcp:8006** only (Proxmox web UI / API)
- Pair with a **PVEAuditor** (read-only) Proxmox API token on the host

See also [proxmox/README.md](../proxmox/README.md).
