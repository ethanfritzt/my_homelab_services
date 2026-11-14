# AdGuard Home (LXC 102)

AdGuard runs in LXC **102** (`adguard`) at **192.168.1.53**. There is no AdGuard YAML committed in this repo.

## Role

- LAN recursive DNS for DHCP clients (router hands out `.53` only; no secondary DNS)
- Upstream: Quad9 DoH
- Blocklists: **disabled**
- Filtering engine: **on** (required for DNS rewrites)

## Rewrite

| Pattern | Answer |
|---------|--------|
| `*.fritz3.org` | 192.168.1.167 (Docker VM) |

So LAN clients resolve `photo.fritz3.org`, `music.fritz3.org`, and `navihelper.fritz3.org` to the Docker host where Caddy and the backends listen.

## Related

- [docs/network.md](../docs/network.md) — full DHCP/DNS path and why Caddy bypasses AdGuard for ACME
