# Proxmox host

## Host

| Field | Value |
|-------|--------|
| Hostname | `pve` |
| Hypervisor | Proxmox VE 9 |
| LAN IP | 192.168.1.165 |
| CPU | Ryzen 7 5700G |
| RAM | 16 GB |
| Tailscale | Subnet router advertising `192.168.1.0/24` |

## Guests

| ID | Name | Type | Specs / notes |
|----|------|------|----------------|
| 100 | `docker` | VM | Debian 13 at 192.168.1.167; Docker Engine + Compose; services under `/home/ethan/my_homelab_services/<svc>` |
| 101 | `home-assistant` | VM | HAOS 16.3 imported from VDI; 2 cores, 2 GB; OVMF/q35 |
| 102 | `adguard` | LXC | 192.168.1.53; AdGuard Home |

## Tailscale

The Proxmox host runs Tailscale as a subnet router for the LAN (`192.168.1.0/24`). See [docs/tailscale.md](../docs/tailscale.md).

## Planned: Grok Bot read-only access

Planned (not yet configured):

- Tailscale ACL tag `tag:grokbot` with access limited to **tcp:8006** on the Proxmox host
- Proxmox API token with **PVEAuditor** (read-only)

## Backups

TODO: vzdump / Proxmox backup schedule is not set up yet.
