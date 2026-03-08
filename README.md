# Home Server Recovery Runbook

## Environment

Server running:

* Ubuntu
* Docker services (Navidrome, Immich, etc.)
* VirtualBox VM running Home Assistant
* Filesystem: ext4

Issue occurred after **power outage**.

---

# Incident: Kernel Panic on Boot

Error message:

```
Kernel panic - not syncing
VFS: Unable to mount root fs on unknown-block(0,0)
```

### Root Cause

Power outage interrupted disk writes causing **filesystem journal corruption**.

The kernel could not mount the root filesystem.

---

# Primary Fix (Successful)

## 1. Boot into GRUB Recovery Mode

During boot:

```
Shift (BIOS)
or
Esc (UEFI)
```

Select:

```
Advanced options for Ubuntu
```

Then:

```
Recovery Mode
```

---

## 2. Run Filesystem Check

From recovery menu:

```
fsck — Check all file systems
```

This runs:

```
fsck
```

Which repairs:

* inode inconsistencies
* journal corruption
* block allocation errors

After completion:

```
resume — Resume normal boot
```

System successfully booted.

---

# Post-Recovery Steps

## Force Full Filesystem Scan

```bash
sudo touch /forcefsck
sudo reboot
```

Ensures a complete scan on next boot.

---

## Verify Disk Health

Install SMART tools:

```bash
sudo apt install smartmontools
```

Check disk:

```bash
sudo smartctl -a /dev/sda
```

or

```bash
sudo smartctl -a /dev/nvme0n1
```

Important fields to check (all should ideally be `0`):

```
Reallocated_Sector_Ct
Current_Pending_Sector
Offline_Uncorrectable
```

---

# Secondary Issue: Virtual Machine Failure

Error from VirtualBox:

```
VERR_SVM_IN_USE
VirtualBox can't enable the AMD-V extension
Please disable the KVM kernel extension
```

### Cause

KVM kernel modules loaded and reserved hardware virtualization — VirtualBox and KVM cannot coexist.

---

## Fix

Unload KVM modules:

```bash
sudo modprobe -r kvm_amd
sudo modprobe -r kvm
```

Start VM again.

---

## Permanent Fix (Optional)

Blacklist KVM modules so they never load:

```bash
sudo nano /etc/modprobe.d/blacklist-kvm.conf
```

Add:

```
blacklist kvm
blacklist kvm_amd
```

Reboot.

> **Note:** If you eventually migrate from VirtualBox to QEMU/libvirt (recommended below), you will
> want to *remove* this blacklist file, as libvirt relies on KVM.

---

# Alternative Recovery Methods (If Recovery Mode Fails)

## Method 1 — Live USB Repair

Boot from an Ubuntu Live USB, then:

```bash
lsblk
```

Identify your root partition (commonly `/dev/sda2`), then repair:

```bash
sudo fsck -f /dev/sda2
```

Reboot.

---

## Method 2 — Rebuild Initramfs

From a recovery shell:

```bash
mount -o remount,rw /
update-initramfs -u
update-grub
reboot
```

---

# Future-Proofing: Prevention Strategy

## Recommended Priority Order

Tackle these in order — each one builds on the last:

1. **Buy a UPS with USB** — do this first; everything else builds on it
2. **Fix `GRUB_RECORDFAIL_TIMEOUT`** — 10-minute fix, prevents getting stuck at boot screen
3. **Set up NUT with proper Docker shutdown ordering**
4. **Configure restic + Healthchecks.io** for automated verified backups
5. **Add `pg_dump` to backup pipeline** for Immich/Postgres
6. **Migrate VirtualBox → QEMU/libvirt** for Home Assistant
7. **Consider Btrfs** if ever doing a fresh OS install or adding a new data drive

---

## 1. Install a UPS — Most Important

A power outage is the root cause of this entire class of problem. A single UPS purchase prevents it.

**Recommended brands:** APC, CyberPower

**Critical:** Buy one with a **USB connection**, not just a power strip with a battery. The USB port
is what allows the server to detect power loss and shut down gracefully. A "dumb" UPS with no USB
is only surge protection.

Benefits:
* Battery backup during outage
* Graceful shutdown before battery dies
* Surge protection

---

## 2. Fix GRUB_RECORDFAIL_TIMEOUT

After any failed or interrupted boot, GRUB's `RECORDFAIL_TIMEOUT` defaults to `-1`, meaning it will
**wait forever** at the boot menu. If you're not physically present, your server will sit at a
prompt indefinitely after a power event.

Check and fix this in `/etc/default/grub`:

```bash
sudo nano /etc/default/grub
```

Set both values:

```
GRUB_TIMEOUT=5
GRUB_RECORDFAIL_TIMEOUT=5
```

Apply the change:

```bash
sudo update-grub
```

This ensures the server will always attempt to boot automatically, even after an unclean shutdown.

---

## 3. NUT for Automatic Shutdown on Power Loss

NUT (Network UPS Tools) lets your server detect when the UPS switches to battery and initiate a
safe, ordered shutdown before power runs out.

### Install

```bash
sudo apt install nut
```

### Configure

Edit `/etc/nut/nut.conf` and set:

```
MODE=standalone
```

Configure your UPS in `/etc/nut/ups.conf` (check NUT's hardware compatibility list for your
model's driver).

### Shutdown Order Matters

Stop Docker containers **before** the OS shuts down, otherwise databases like Postgres can corrupt
even with a UPS (if the battery runs out mid-shutdown). Add a NUT shutdown command hook:

```bash
# /etc/nut/upsmon.conf — add to SHUTDOWNCMD
SHUTDOWNCMD "docker stop $(docker ps -q) && sleep 5 && /sbin/shutdown -h now"
```

---

## 4. Automated Backups with Restic + Healthchecks.io

The original runbook mentions rsync/borg/restic without emphasizing a critical point: **backups are
useless if you never verify they work.** A backup job that silently fails for three months is the
same as no backup at all.

**Restic** is the strongest modern choice — it deduplicates, compresses, encrypts, and has a built-in
integrity check command.

### Install Restic

```bash
sudo apt install restic
```

### Initialize a Repository

```bash
restic init --repo /srv/backups/restic-repo
```

### Example Backup Script

```bash
#!/bin/bash
# /usr/local/bin/backup.sh

RESTIC_REPOSITORY="/srv/backups/restic-repo"
RESTIC_PASSWORD_FILE="/etc/restic-password"

restic -r $RESTIC_REPOSITORY backup \
  /srv/music \
  /srv/docker \
  /srv/postgres \
  --exclude /srv/docker/tmp

restic -r $RESTIC_REPOSITORY forget \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 6 \
  --prune
```

### Verify Backup Integrity

```bash
restic -r /srv/backups/restic-repo check
```

### Monitor with Healthchecks.io (Free Tier)

Healthchecks.io will alert you if your backup job stops running or fails. Add a ping at the end of
your backup script:

```bash
curl -fsS --retry 3 https://hc-ping.com/YOUR-UUID-HERE > /dev/null
```

If the ping doesn't arrive on schedule, you get an email. This means a silently failing cron job
won't go unnoticed.

### Schedule with Cron

```bash
sudo crontab -e
```

Add:

```
0 3 * * * /usr/local/bin/backup.sh >> /var/log/restic-backup.log 2>&1
```

---

## 5. Database Backup for Immich/Postgres

A filesystem snapshot alone is **not sufficient** for a running Postgres database. The data files
may be in an inconsistent state mid-write. Always dump Postgres before your nightly restic backup.

Add this before your restic backup job:

```bash
# Dump Immich Postgres before backup
docker exec immich_postgres pg_dumpall -U postgres \
  > /srv/backups/immich_$(date +%F).sql
```

Rotate old dumps to avoid filling disk:

```bash
# Keep last 7 daily dumps
find /srv/backups/ -name "immich_*.sql" -mtime +7 -delete
```

---

## 6. Migrate VirtualBox → QEMU/libvirt for Home Assistant

The AMD-V conflict with KVM is a recurring problem that will come back every time KVM loads. The
root issue is that **VirtualBox and KVM cannot coexist** — they both want exclusive access to
hardware virtualization.

Since you're already on Linux, QEMU/KVM with libvirt is the better long-term fit. The Home Assistant
project itself recommends this for Linux hosts.

Benefits over VirtualBox:
* Native Linux virtualization — no AMD-V conflicts
* Better I/O performance for Home Assistant
* Managed by standard Linux tooling (virsh, virt-manager)
* Works alongside Docker without module conflicts

### Install

```bash
sudo apt install qemu-kvm libvirt-daemon-system virt-manager
sudo usermod -aG libvirt $USER
```

### Remove the KVM Blacklist

If you previously blacklisted KVM modules (from the fix above), remove that file before using libvirt:

```bash
sudo rm /etc/modprobe.d/blacklist-kvm.conf
sudo reboot
```

### Import Your Home Assistant VM

Export your existing VM from VirtualBox as an `.ova` file, then import:

```bash
virt-convert homeassistant.ova -o virt-image
```

Or start fresh — the Home Assistant project provides a `.qcow2` image for KVM/QEMU directly at
[https://www.home-assistant.io/installation/linux](https://www.home-assistant.io/installation/linux).

---

## 7. Use a More Resilient Filesystem (Long-Term)

The original runbook suggests ZFS or Btrfs. Both are valid, but with important caveats:

| Filesystem | Benefit | Caveat |
|------------|---------|--------|
| ZFS | Checksums, self-healing, excellent for RAID | Memory-hungry — wants 8GB+ RAM for ARC cache |
| Btrfs | Snapshots, corruption detection, in-kernel | Less mature than ZFS for RAID configs |
| ext4 (current) | Stable, simple | No checksums, no snapshots |

**Recommendation:** For a typical homelab media server, **Btrfs is the more practical choice.**
It's already in the Linux kernel, requires no extra RAM, handles snapshots well, and pairs cleanly
with Docker bind mounts.

> **Note:** Migrating your root filesystem is disruptive — you'd need to back everything up and
> reinstall. This is worth doing eventually but is the lowest priority item on this list. Consider
> it the next time you do a fresh OS install or add a new data drive.

---

## 8. Postgres Durability Settings

For any Postgres instance (including Immich's), these settings ensure safe crash recovery:

```
synchronous_commit = on
full_page_writes = on
wal_sync_method = fdatasync
```

Apply these in your `postgresql.conf` or via Docker environment variables, then restart the container.

---

## 9. Docker Storage Best Practice — Bind Mounts

Never rely on Docker's container overlay storage for persistent data. Always use bind mounts so
your data lives at a known path on the host filesystem and survives container re-creation.

```yaml
volumes:
  - /srv/postgres:/var/lib/postgresql/data
  - /srv/music:/music
  - /srv/immich:/usr/src/app/upload
```

---

## 10. Fix systemd Service Dependencies

After a rough reboot, Docker services sometimes race and fail to start because Docker wasn't ready
in time. Ensure your service unit files declare proper ordering:

```ini
[Unit]
After=network-online.target docker.service
Requires=docker.service
```

Check your existing services:

```bash
sudo systemctl cat docker-compose@.service
```

---

## 11. Out-of-Band Access (Remote Recovery)

If this happens again while you're away from home, how do you recover? Consider:

* **Tailscale** — install on your server so you can SSH in after a partial boot, even without port
  forwarding on your router. Free for personal use.
* **Raspberry Pi as serial console** — connect a Pi to your server via serial/USB and get a
  terminal even if the network is down.

At minimum, install Tailscale now as a safety net:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

---

# Recommended Server Directory Layout

```
/srv
 ├── docker/         # Docker bind mount data
 ├── postgres/       # Postgres data directory
 ├── music/          # Navidrome music library
 ├── immich/         # Immich media uploads
 └── backups/        # Restic repo + pg_dumps
```

---

# Summary

**Primary failure cause:**

```
Power outage → filesystem journal corruption → kernel panic
```

**Recovery:**

```
GRUB → Recovery Mode → fsck → resume
```

**Future protection — in priority order:**

| # | Action | Impact |
|---|--------|--------|
| 1 | UPS with USB | Prevents the outage from reaching the server |
| 2 | Fix GRUB_RECORDFAIL_TIMEOUT | Prevents stuck boot screen |
| 3 | NUT + Docker shutdown ordering | Graceful shutdown before battery dies |
| 4 | Restic + Healthchecks.io | Verified, monitored backups |
| 5 | pg_dump before backup | Safe Postgres snapshots |
| 6 | Migrate to QEMU/libvirt | Eliminate AMD-V conflicts permanently |
| 7 | Btrfs (next fresh install) | Checksums + snapshots at the filesystem level |
