# Mini Cameras V2 — bill of materials

Prices checked **2026-11-15**. US list prices, before tax and shipping.

camone and camtwo stay on the Pi Zero W. This list is only the **next** camera: a smaller board, a better picture than the OV5647 running at 640×480, and a parts total under a Blink Mini 2.

## Recommendation

Buy a **Luckfox Pico Mini A** and a **SC3336** camera. Board plus camera is **$20.98**.

| Qty | Part | Price | Why this one |
|-----|------|------:|--------------|
| 1 | [Luckfox Pico Mini A](https://www.luckfox.com/Mini-PC/Luckfox-Pico-Mini-A) (RV1103, USB-C, CSI, no headers) | $11.99 | **28 × 21 mm**. The Pi Zero is 65 × 30 mm. Hardware H.264/H.265, ISP, no micro-HDMI and no full-size USB to design around |
| 1 | [SC3336 3MP camera (B)](https://www.luckfox.com/index.php?path=241&route=product%2Fcategory) | $8.99 | 1/2.8" sensor, F2.0, 98° diagonal, 2304×1296 @ 30. Low-light part, with the cable |
| | **Board + camera** | **$20.98** | |

Power it from a USB-C cable and a 5 V charger already in the house. The CanaKit brick is micro-USB, so it needs a different cable, not a second supply. The Mini A boots from a microSD; a spare small card is enough, and the Mini B (128 MB flash, no SD) is one of the options in that page’s **$11.99–$18.99** range. Filament for the shell is about a dollar and belongs to the enclosure task.

The Mini has **no Wi-Fi**. The Pis are on 2.4 GHz, so a wireless node needs one of these instead:

| Path | Parts | Total | Size |
|------|-------|------:|------|
| Cheapest, wired or a USB Wi-Fi stick later | Mini A + SC3336 | **$20.98** | 28 × 21 mm board |
| Wi-Fi on the board | [Core110612N256](https://www.luckfox.com/Core1106) (30 × 30 mm, Wi-Fi 6, 256 MB NAND) + SC3336 | **$39.98** | 30 × 30 mm module |

Core110612N256 is listed at **$30.99** on Luckfox’s RV1106 page. The Core1106 family starts at $26.99. It is a castellated module: USB-C power and the CSI socket land on a tiny carrier, which can be the floor of the printed shell. That is still half the Pi Zero’s length, and **$39.98** matches a Blink Mini 2’s hardware price with the picture and the size on this side of the comparison.

Luckfox’s MIS5001 5MP module is **$14.99** and is the step up if the megapixel number has to beat the OV5647. It needs the RV1106 (the Core1106 or a Pico Pro), because the Mini’s ISP stops at 4 MP. Core + MIS5001 is about **$46**, which is the line where the parts stop being cheaper than a Mini 2. Leave that for a second buy after the SC3336 picture is in MediaMTX.

### Why this camera is the upgrade

The OV5647 is a 5 MP sensor, and the nodes publish **640×480 @ 15 fps**. The extra pixels never leave the Pi.

| | Arducam OV5647 (in use) | SC3336 |
|--|-------------------------|--------|
| Sensor | 1/4" | 1/2.8" (about four times the area) |
| What you actually get | 640×480 H.264 | 2304×1296 @ 30, H.264 or H.265 in hardware |
| Lens | ~54° horizontal, daylight | F2.0, 98° diagonal, high-sensitivity / low light |
| Encode | `rpicam-vid` on a single-core Zero | RV1103 ISP (HDR, WDR, noise reduction) plus a hardware encoder |

A 3 MP security sensor on a larger die, run at its real resolution, is a better camera for this house than a 5 MP module pinned at 480p. An 8 MP IMX415 is **$48.99** by itself on Luckfox and uses 4-lane CSI. That single part costs more than the whole Mini + SC3336 node.

MediaMTX already ingests video on the Docker VM. The Mini and the Core speak H.264/H.265, so the new firmware publishes RTSP (or the same UDP MPEG-TS) and a path gets added in `mediamtx/mediamtx.yml`. `publish-stream.sh` stays the Pi path.

## Why the first total was ~$51

That number was a full retail rebuild, then a second copy of the same camera on a bigger dev board.

- Pi Zero W at Adafruit ($15) + CanaKit supply ($8) + Arducam OV5647 ($16.99) + a new SD card and filament came to **$50.99**. The supply, the cards, and both cameras are already owned.
- The ESP32-P4 pick was a Waveshare dev board at $24.99 (**about 71 × 21 mm**, longer than the Pi) plus another OV5647 at $16.99, plus another $8 supply. Same sensor, larger board, **$51–$59**.

Those are real shelf prices. They are the wrong shopping list for a smaller shell.

## Price against Blink

The plug-in camera to beat is the **Blink Mini 2 at $39.99** (1080p, 51 × 51 × 40 mm, IR and a spotlight, USB-C supply in the box). Without a plan, live view is 60 seconds. Basic is **$39.99/year per camera** and adds cloud clips, person detection, and 90-minute live view. Plus is **$119.99/year** for unlimited cameras, and it costs more than two Basic plans.

| Setup | Hardware | 3-year plan | 3-year total |
|-------|--------:|------------:|-------------:|
| Pico Mini A + SC3336 | $20.98 | $0 | $20.98 |
| Core1106 Wi-Fi + SC3336 | $39.98 | $0 | $39.98 |
| Blink Mini 2, no plan | $39.99 | $0 | $39.99 |
| Blink Mini 2 + Basic | $39.99 | $119.97 | $159.96 |
| Two Mini + SC3336 nodes | $41.96 | $0 | $41.96 |
| Two Mini 2 + two Basic plans | $79.98 | $239.94 | $319.92 |

The $21 node is about half the Mini 2’s hardware price, and the shell can be much smaller than 51 mm. The $40 Wi-Fi module ties the Mini 2 on sticker price and still has continuous live view in Home Assistant (`rtsp://192.168.1.167:8554/<path>`) with no account. One year of Basic costs as much as the Mini 2 again.

Night vision is still Blink’s advantage. The SC3336 is a low-light color sensor, not an IR illuminator. Add IR only for a spot that is actually dark, after the daytime picture is proven.

## What not to buy for the shell

| Option | Why it missed |
|--------|----------------|
| ESP32-P4 dev board + OV5647 | ~71 mm long, same sensor as today, ~$51 |
| XIAO ESP32-S3 Sense | Smallest board here (21 × 17.5 mm, $19.99 with an OV2640). The picture is a step down, and the S3 sends MJPEG, which is heavy on 2.4 GHz and does not join the MediaMTX paths |
| ESP32-CAM + OV2640 | ~$12–$15 and ~40 × 27 mm. Same MJPEG limit, weaker antenna |
| Luckfox Pico Zero | Wi-Fi 6 and 4-lane CSI, **$42.99**, and the board is about **65 × 30 mm**. Same outline as the Pi, higher price, before a camera |
| Luckfox Pico Ultra W | Wi-Fi on the board, about **50 × 50 mm**, and the W versions sit in a **$40.99+** range before the camera. Square is Blink-sized, not smaller than the Pi |
| Another Pi Zero W + OV5647 | $41–$51 to rebuild a node you already have, and the stream stays 640×480 |
| Pi Zero 2 W | $19.05, same 65 × 30 mm outline. Only useful if a current Pi is out of CPU |

## V1 parts (already built)

Replacement prices, if a Pi node has to be built again. Not the V2 buy.

| Part | Price | Notes |
|------|------:|-------|
| Raspberry Pi Zero W | $15.00 | [Adafruit](https://www.adafruit.com/category/933), in stock. CanaKit $16.35, sold out. Zero WH $16.00 |
| CanaKit micro-USB supply | $8.00 | [5.1 V / 2.5 A](https://www.canakit.com/raspberry-pi-3-zero-power-supply-micro-usb.html). Already in use |
| Arducam OV5647 | $16.99 | [B0033+B0087](https://www.arducam.com/b0033b0087-arducam-5mp-ov5647-mini-camera-video-module-with-15-pin-1-0mm-pitch-to-22-pin-0-5mm-and-15pin-to-15pin-1-0mm-ribbon-cable-for-raspberry-pi-model-a-b-b-pi-2-pi-3-pi-4-and-pi-zero.html). [B0033](https://www.arducam.com/arducam-ov5647-standard-raspberry-pi-camera-b0033.html) was on special at $6.99 |
| microSD | spare | 8 GB+ Class 10 / A1 is enough. A new 32 GB card is about $10 if there is no spare |
| **Rebuild, using the supply you have** | **$31.99** | Board + the $16.99 camera. **$50.99** only if you also buy a new supply, a new SD, and filament |

CanaKit’s Zero W MAX kit is $79.99 on Amazon. It adds a plastic case, an HDMI adapter, and an OTG cable this setup does not use.

## Sources

Checked 2026-11-15.

- Luckfox Pico Mini A $11.99, options $11.99–$18.99, outline 28 × 21 mm: [Luckfox](https://www.luckfox.com/Mini-PC/Luckfox-Pico-Mini-A), [CNX Software](https://www.cnx-software.com/2024/08/16/luckfox-pico-mini-tiny-arm-linux-camera-board-rockchip-rv1103-64mb-ram/)
- SC3336 $8.99, MIS5001 $11.99 and $14.99, IMX415 $48.99: [Luckfox cameras](https://www.luckfox.com/index.php?path=241&route=product%2Fcategory)
- SC3336 specs (1/2.8", 2304×1296, F2.0, 98.3°): [Amazon listing](https://www.amazon.com/SC3336-3MP-Camera-Sensitivity-Performance/dp/B0DMF456FW), also $15.35 there if you do not want to order from Luckfox
- Core1106 family from $26.99, 30 × 30 mm, Wi-Fi optional, H.264/H.265: [Luckfox](https://www.luckfox.com/Core1106). Core110612N256 at $30.99 on the [RV1106 tag page](https://www.luckfox.com/index.php?limit=75&order=ASC&route=product%2Fsearch&sort=pd.name&tag=RV1106)
- Pico Zero $42.99, about 65 × 30 mm, Wi-Fi 6, 4-lane CSI: [Luckfox](https://www.luckfox.com/Luckfox-Pico-Zero)
- Pico Ultra outline 50 × 50 mm, W versions from about $41: [CNX Software](https://www.cnx-software.com/2024/06/21/luckfox-pico-ultra-micro-development-board-features-mipi-csi-wifi-6-ethernet-poe-gpio-headers/), [Luckfox](https://www.luckfox.com/EN-Luckfox-Pico-Ultra)
- Pi Zero W $15, Zero 2 W $19.05: Adafruit. CanaKit supply $8. Arducam OV5647 $16.99 / $6.99
- XIAO ESP32-S3 Sense $19.99: Seeed. ESP32-CAM boards on Amazon from $11.99. Waveshare ESP32-P4-WIFI6 $24.99, outline ~71 × 21 mm
- Blink Mini 2 $39.99, Outdoor 4 with Sync Core $79.99: [Security.org](https://www.security.org/security-cameras/blink/). Plans: [Home Security Radar](https://homesecurityradar.com/guides/does-blink-require-subscription). Live view limits: [Blink Mini 2 FAQ](https://support.blinkforhome.com/en_US/mini-2-faq)
