# Mini Cameras V2 — bill of materials

Prices checked **2026-11-15**. US list prices, before tax and shipping. Rows marked *allowance* are planning numbers, not a single store SKU.

camone and camtwo stay as they are: Pi Zero W, Arducam OV5647, CanaKit micro-USB supply, printed shell, 640×480 @ 15 fps H.264 into MediaMTX. This list is the cost to build the **next** camera, and how that compares with Blink.

## Recommendation

Prototype the next camera on an **ESP32-P4 + ESP32-C6** with an **OV5647**, then design the shell around that board.

The P4 is the Espressif chip with a hardware H.264 encoder (1080p30) and a MIPI-CSI port, so it can use the same sensor family as the Pis. An ESP32-CAM or a XIAO ESP32-S3 Sense is smaller and cheaper, and both send MJPEG. They cannot run `publish-stream.sh`, and a JPEG stream at the resolution the Pis already publish uses several times the 2.4 GHz airtime.

Buy one board and prove it can publish H.264 to MediaMTX before printing a fleet of shells or ordering more.

### Prototype buy

| Qty | Part | Price | Where |
|-----|------|------:|-------|
| 1 | Waveshare ESP32-P4-WIFI6 (P4 + C6 Wi-Fi 6, USB-C, CSI, mic, speaker header, no camera) | $24.99 | [Amazon](https://www.amazon.com/Waveshare-ESP32-P4-WIFI6-High-Performance-Development-Pre-soldered/dp/B0FKH4KK7M) |
| 1 | Arducam 5MP OV5647 mini, Pi Zero cable bundle (B0033+B0087) | $16.99 | [Arducam](https://www.arducam.com/b0033b0087-arducam-5mp-ov5647-mini-camera-video-module-with-15-pin-1-0mm-pitch-to-22-pin-0-5mm-and-15pin-to-15pin-1-0mm-ribbon-cable-for-raspberry-pi-model-a-b-b-pi-2-pi-3-pi-4-and-pi-zero.html) |
| 1 | USB-C 5V supply | $8 allowance | Same class as the CanaKit brick below. That brick is micro-USB and will not plug into this board |
| — | Printed shell, filament | $1 allowance | Enclosure design is a separate task |
| | **Prototype** | **$50.98** | |

Budget another **$7.67** for a [Waveshare Pi 5 CSI cable](https://www.amazon.com/s?k=waveshare+CSI+FPC+Pi+5+22pin+15pin) (22-pin to 15-pin) if the Arducam flex is the Pi Zero pinout and the P4 board wants the Pi 5 pinout. That takes the prototype to **$58.65**.

If Arducam’s B0033 special ($6.99, includes both the 15-pin and 22-pin cables) is still up and the cable fits, the prototype is **$40.98**.

Leave the Waveshare 3.5 inch kit ($49.99, OV5647 included) on the shelf. The panel makes that board about 101 × 62 mm, which is larger than the Pi Zero.

DFRobot lists a FireBeetle 2 ESP32-P4 kit at $18.50 with CSI and Wi-Fi 6. The listing was not confirmed to include a camera, so it is not in the total.

## Price target

The plug-in camera to beat is the **Blink Mini 2 at $39.99** (1080p30, 143° diagonal, 2.4 GHz, 51 × 51 × 40 mm, USB-C supply in the box, 850 nm IR plus a spotlight). The Outdoor 4 kit is **$79.99** with a Sync Module Core. It is a battery camera that records motion clips, so it is a weak stand-in for an always-on stream.

Without a plan, Mini 2 live view is 60 seconds, and tapping continue stretches a session to five minutes. A plan raises live view to 90 minutes and adds cloud clips and person detection.

| Plan | Monthly | Yearly | Devices |
|------|--------:|-------:|---------|
| Basic | $3.99 | $39.99 | 1 |
| Plus | $11.99 | $119.99 | Unlimited |

Plus costs more than two Basic plans. It starts winning at four cameras (3 × $39.99 = $119.97).

| Setup | Hardware | Subscription, 3 years | 3-year total |
|-------|--------:|----------------------:|-------------:|
| One V1 Pi node, rebuilt | $50.99 | $0 | $50.99 |
| One P4 prototype, cable fits | $50.98 | $0 | $50.98 |
| One P4 prototype + spare FFC | $58.65 | $0 | $58.65 |
| One Blink Mini 2, no plan | $39.99 | $0 | $39.99 |
| One Blink Mini 2 + Basic | $39.99 | $119.97 | $159.96 |
| Two V1 nodes, rebuilt | $101.98 | $0 | $101.98 |
| Two Mini 2 + two Basic plans | $79.98 | $239.94 | $319.92 |
| Two Mini 2 + Plus | $79.98 | $359.97 | $439.95 |

camone and camtwo are already paid for. Keeping them is $0. The table is the cost of the next build, and of buying Blink instead.

A P4 node lands about **$11–$19** above a bare Mini 2. Mini 2 + Basic is **$159.96** over three years, against **$51–$59** for the local camera. The hardware premium is gone before the first year of Basic is over. What that premium buys here:

- Continuous live view in Home Assistant (`rtsp://192.168.1.167:8554/<path>`), instead of a 60-second or 90-minute session in the Blink app
- No Blink account and no per-camera plan
- Room to move off today’s 640×480 @ 15 fps once P4 firmware publishes H.264 (the encoder itself does 1080p30)
- A flatter board (~71 × 21 mm versus the Pi Zero’s 65 × 30 mm) so the printed shell can be thinner

A Mini 2 with no plan is the lower hardware price, and it still has no RTSP, no Home Assistant stream, and no saved clips.

## Boards side by side

| | V1 Pi Zero W | ESP32-CAM (OV2640) | XIAO ESP32-S3 Sense | ESP32-P4 + C6 | Blink Mini 2 |
|--|--------------|--------------------|---------------------|---------------|--------------|
| Outline | 65 × 30 × 5 mm | ~40 × 27 mm | 21 × 17.5 mm | ~71 × 21 mm | 51 × 51 × 40 mm |
| Power | micro-USB 5 V | 5 V, sags into brownouts | USB-C | USB-C | USB-C, supply included |
| Sensor | OV5647 5MP, streamed at 640×480 | OV2640 2MP | OV2640 included; OV5640 is +$11.99 | MIPI-CSI, OV5647 | 1080p |
| Codec | H.264 (`rpicam-vid`) | MJPEG | MJPEG | H.264 in hardware, 1080p30 | H.264 |
| MediaMTX today | UDP MPEG-TS on the existing paths | Needs a new ingest | Needs a new ingest | After firmware publishes RTSP or UDP MPEG-TS | No RTSP |
| Night | Daylight, IR-cut filter | Flash LED on many boards | Daylight | Depends on the module | 850 nm IR and a spotlight |
| Audio | None on the current nodes | Usually none | Microphone | Microphone and a speaker header | Microphone and speaker |
| Storage | microSD | Optional | microSD slot | Optional | Cloud, or a Sync Module 2 (~$50) plus a USB stick |
| One new node | $50.99 | $23.99 | $28.99 | $50.98–$58.65 | $39.99 |

ESPHome can show an ESP32-CAM or XIAO picture in Home Assistant. That would be a second kind of camera, with its own heat, antenna, and power problems, and it would not join `zero` / `one` on MediaMTX.

## V1 parts (camone and camtwo)

| Part | Price | Notes |
|------|------:|-------|
| Raspberry Pi Zero W | $15.00 | [Adafruit](https://www.adafruit.com/category/933), in stock. CanaKit lists $16.35 and is sold out. Zero WH (headers) is $16.00 |
| Raspberry Pi Zero 2 W | $19.05 | [Adafruit](https://www.adafruit.com/product/5291), out of stock when checked. Same 65 × 30 mm outline, so the shell does not shrink. Worth it only if a current node is CPU-bound |
| CanaKit / official micro-USB supply | $8.00 | [5.1 V / 2.5 A](https://www.canakit.com/raspberry-pi-3-zero-power-supply-micro-usb.html). This is the supply already in the cameras |
| Arducam OV5647 | $16.99 | [B0033+B0087](https://www.arducam.com/b0033b0087-arducam-5mp-ov5647-mini-camera-video-module-with-15-pin-1-0mm-pitch-to-22-pin-0-5mm-and-15pin-to-15pin-1-0mm-ribbon-cable-for-raspberry-pi-model-a-b-b-pi-2-pi-3-pi-4-and-pi-zero.html), Zero flex included. Fixed focus, about 54° horizontal, IR-cut. [B0033](https://www.arducam.com/arducam-ov5647-standard-raspberry-pi-camera-b0033.html) was on special at $6.99 with both cables |
| Arducam OV5647 spy module | $17.99 | [B006603](https://www.arducam.com/blog/product/b006603-arducam-for-raspberry-pi-zero-camera-module-1-4-inch-5mp-ov5647-spy-camera-with-flex-cable-for-pi-zero-and-pi-compute-module/), about 60 × 11.5 mm with a narrow lens neck, if a shell needs that shape. Pi Zero / Compute Module |
| microSD, 32GB A1 / Class 10 | $10 allowance | 8GB+ is enough. Adafruit’s official 32GB A2 card was $13.69 and is no longer stocked |
| Printed enclosure | $1 allowance | Filament for one small shell |
| **Rebuilt node** | **$50.99** | **$40.99** if the $6.99 Arducam special is used |

CanaKit’s Zero W MAX kit (64GB card, supply, plastic case, HDMI adapter, OTG cable) is $79.99 on Amazon and $89.95 at CanaKit. The case and adapters are unused once the shell is printed, so the kit is the expensive way to buy this node.

## ESP32-CAM (AI-Thinker style, OV2640)

| Part | Price |
|------|------:|
| Board with OV2640 | $11.99 |
| Board plus micro-USB programmer (MB) | $14.99. A 2-pack with programmers is $29.99 |
| 5V supply | $8 allowance. The CanaKit micro-USB brick can power the programmer board |
| Shell | $1 allowance |
| **First node** | **$23.99** |
| **Next node** | **$20.99** (one programmer is enough for the fleet) |

Cheapest way to see a picture. The PCB antenna, the 5 V rail, and the missing H.264 encoder are the reasons to keep it off the real cameras.

## Seeed XIAO ESP32-S3 Sense

| Part | Price |
|------|------:|
| XIAO ESP32-S3 Sense (OV2640, mic, microSD, USB-C, LiPo charge) | $19.99 at [Seeed](https://www.seeedstudio.com/XIAO-ESP32S3-Sense-p-5639.html). Amazon had it at $25.99 |
| OV5640 for this board, with heatsink | $11.99 optional. Still JPEG/MJPEG off the S3 |
| USB-C 5V supply | $8 allowance |
| Shell | $1 allowance |
| **Base node** | **$28.99** |
| **With the OV5640** | **$40.98** |

This is the board for a shell that has to be smaller than the Mini 2 cube. The stacked sense board is about 21 × 17.5 × 15 mm. Use it as an ESPHome camera. Leave MediaMTX on the Pis and, if the prototype works, on the P4.

## ESP32-P4 detail

| Part | Price | Notes |
|------|------:|-------|
| Waveshare ESP32-P4-WIFI6 | $24.99 | Wi-Fi is the onboard ESP32-C6: 2.4 GHz Wi-Fi 6, same band as the Pis and Blink. USB-C for power and flashing. Outline of this board family is about 71 × 21 mm |
| Arducam OV5647 | $16.99 or $6.99 | Same sensor as V1. Confirm the flex pinout before soldering the shell design around it |
| Pi 5 CSI FFC | $7.67 | Only when the camera cable is the wrong pinout |
| USB-C supply | $8 allowance | |
| Shell | $1 allowance | |
| 3.5 inch kit with OV5647 | $49.99 | [Amazon](https://www.amazon.com/Waveshare-ESP32-P4-WIFI6-Development-Resolution-Microphone/dp/B0GS9JCJPY). Camera is in the box. The screen is why the board is large |
| **Prototype** | **$50.98–$58.65** | See the buy list above |

`publish-stream.sh` stays the Pi path (`rpicam-vid` → UDP MPEG-TS). MediaMTX already listens on those UDP ports (`mediamtx/mediamtx.yml`). A P4 build can publish the same way, or publish RTSP and let MediaMTX pull it. That firmware is the gate before any second P4.

### Night vision

The Mini 2’s IR and spotlight are the capability the daylight OV5647 does not have. The current Pis do not have it either.

Waveshare’s OV5647 IR-cut kit (removable IR-cut, two IR LED boards, 31 × 32 mm) is **$35.99**. Using it instead of the $16.99 Arducam puts a P4 prototype around **$70** before a spare cable, or about **$78** with the $7.67 FFC. That matches roughly one year of Mini 2 + Basic ($79.98) and stays under the three-year Blink total ($159.96), with IR on the local stream.

Add this only for a spot that is actually dark. A hallway with a light does not need it.

## What to leave alone

- camone (`192.168.1.234`) and camtwo (`192.168.1.171`). A new shell does not help a camera that is already mounted, and there is no P4 firmware in this repo yet.
- An ESP32-CAM fleet. The $21 second-unit price loses the comparison once the picture has to stay on MediaMTX.
- A Zero 2 W swap as a size project. Same board outline. It is the upgrade if a current Pi runs out of CPU, which is a different change than a smaller shell.

## Sources

Checked 2026-11-15.

- Pi Zero W $15, Zero WH $16, Zero 2 W $19.05: Adafruit
- CanaKit Zero W $16.35 (sold out), MAX kit $79.99 Amazon / $89.95 CanaKit, micro-USB supply $8
- Arducam OV5647 $16.99 (B0033+B0087), $6.99 special (B0033), spy module $17.99 (B006603)
- Seeed XIAO ESP32-S3 Sense $19.99, OV5640 $11.99. Amazon Sense listing $25.99
- ESP32-CAM on Amazon: board $11.99, board + programmer $14.99, 2-pack with programmers $29.99
- Waveshare ESP32-P4-WIFI6 $24.99; 3.5 inch OV5647 kit $49.99; Pi 5 CSI cable $7.67; IR-cut OV5647 kit $35.99
- P4 board family outline ~71 × 21 mm: Kamami listing for the ESP32-P4-WIFI6 kit
- Blink hardware: [Security.org, 2026](https://www.security.org/security-cameras/blink/) (Mini $29.99, Mini 2 $39.99, Outdoor 4 with Sync Core $79.99)
- Blink plans after the October 2025 increase: Basic $3.99/mo or $39.99/yr, Plus $11.99/mo or $119.99/yr ([Home Security Radar](https://homesecurityradar.com/guides/does-blink-require-subscription))
- Mini 2 specs, IR, and live-view limits: [Blink tech specs](https://blink.helpjuice.com/en_US/mini-2-tech-specs), [Blink Mini 2 FAQ](https://support.blinkforhome.com/en_US/mini-2-faq)
- Sync Module 2 about $50, for local clip storage: The Verge, Mini 2 review
- FireBeetle 2 ESP32-P4 listed at $18.50 on DFRobot. Unverified; the page did not load during this check
