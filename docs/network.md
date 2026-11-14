# Network

## Addresses

| Host | IP |
|------|-----|
| Nighthawk RS70 (router) | 192.168.1.1 |
| AdGuard LXC (`adguard`) | 192.168.1.53 |
| Proxmox (`pve`) | 192.168.1.165 |
| Docker VM (`docker`) | 192.168.1.167 |

LAN: `192.168.1.0/24`.

## DHCP / DNS flow

1. Router DHCP assigns clients **192.168.1.53** as their DNS server (no secondary).
2. AdGuard answers LAN queries:
   - Upstream for general recursion: Quad9 DoH
   - Rewrite: `*.fritz3.org` → `192.168.1.167`
3. Clients therefore reach Immich / Navidrome / navidrome-helper via Caddy on the Docker VM.

## Why Caddy uses `dns: [1.1.1.1, 8.8.8.8]`

AdGuard rewrites `*.fritz3.org` to the private Docker IP. Cloudflare DNS-01 ACME validation must see the **real** public DNS records for `fritz3.org`, not the LAN rewrite. The Caddy container is configured with public resolvers (`1.1.1.1`, `8.8.8.8`) so ACME DNS-01 lookups bypass AdGuard.
