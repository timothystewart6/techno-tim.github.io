---
layout: post
title: "My 2026 Homelab Tour (Rack + Servers + Network + Storage)"
date: 2026-02-26 08:00:00 -0500
categories: homelab
tags: homelab hardware unifi network poe proxmox kubernetes truenas ups nas
image:
 path: /assets/img/headers/homelab-hardware-tour-2026-hero.webp
 lqip: data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APxU8Tft8at4Z+DfgPwp4o8OaR4h8D/D74Kfs1+I9T8I6n4K8J+NtG1jRIr34aadqFrfaX8QZNe0PXZfs/ivX5tI0260fS47C8e2v31qfVlTVbb63OcTifqmc/UsPh3UlkeVYrB4OpiKuGwixEnl0oUZ4lUMdiMPQnUnGFSuqOLrRpxU3TxEoqEvmcsw9L22VKvVqWp5xmdHEYqNClWxEqUVmcJVFS58NSqVFGPOqfPh6cp6KVKLuvyk8WftkeHdW8U+JdU0b4M+CrTSNS8QazqGlWi+DPhPo4tdNvNRubixtxpOnfDW40/SxDayRRjTrC4nsrIL9mtZpYIkdvkKNTESo0pYnlpYmVKnLEU6NaeIo067inVhSxFSlhqlelCpzRp1p4bDzqxSnKhScnTj9PUjTVSao3nSU5KlOpCNKpOmpNQlOlGVaNOco2cqcatWMJNxVSaXM/8A/9k=
---

My homelab has changed again… 2026.

This year turned into a full evolution: **network upgrades**, **compute refreshes**, **storage testing**, and a bunch of **power/UPS changes** that change how I run (and recover) everything.

Self-hosting guide next - subscribe for the follow up.

{% include embed/youtube.html id='-KJ0jmUgAmw' %}
[Watch the video](https://www.youtube.com/watch?v=-KJ0jmUgAmw)

---

## The wall of tech (everything that doesn’t fit the rack)

Before we even touch the rack, let’s start with the wall stuff that keeps everything running:

- **Internet coming in**: I have two fiber lines coming to the house - one buried line coming in from the front, and one coming in from the back of the house overhead/from the pole - but I’ve fully switched to one provider as the primary which is Quantum Internet.
- **Old fiber ONT**: my previous fiber gear is still here, but currently unplugged.  USI, while great, is twice the price and half the speed of Quantum.  I used them for years, and a great service, but I am able to have fiber internet with Quantum + T-Mobile 5G Home Internet as a backup for the same price.  USI needs to lower their price now that they have real competition.
- **Backup internet (5G)**: my backup right now is **T-Mobile Home Internet over 5G** - it’s cheaper than keeping a second fiber line, and it’s already failed over a few times without issues when my primary internet goes down. I was also hoping to use it with the **UniFi 5G Max**, but the SIM is locked to T-Mobile’s gateway.
- **UniFi phone**: mounted on a 3D-printed bracket from earlier testing (I don’t run UniFi Talk full time, I was only testing it).
- **Hue hubs (yes, four)**: I still run multiple Hue hubs because of **Hue Play** - I have three Play setups, and each one needs its own hub.
- **Small PoE switch (wall)**: PoE powers a small switch on the wall, which the Hue hubs connect through.
- **Whole-home wiring**: this is where all the home cable runs land; it’s older Cat5e, punched down and still doing the job (yes, even for 10Gb in places).
![Wall of Tech](/assets/img/posts/homelab-2026/homelab-2026-wall-of-tech.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APZ/gZ+3rc/Ga+8OHw18PbPSJfDPxjm+HbTapfx2d9Z+Io7vR/iHJqvh/V9Ls7zUdP0G80jxP4Y0O800yC9lnsPEDNevpeprpz+dVy6nhMro16k3VcXJWcU01ThCPK4ybjJXva+lrXVzvWc4jE5pPD4enGhCUPe5pXkpylU96E4wUop2i5K921L3rSsv1Qh+M/iySKKS70LRpruSNHupk1MRJLcMoaaVIl8NbYlkkLOsa/KgIUcCvEU4NJqU0mrpckXZPW1/aa279T3Ob+ZJy6uyV31dkrK71stj/9k=" }
_The wall of tech_

### Power outages: coordinated shutdown

One of the most important reliability pieces I have in place is what happens when the power goes out.

- This Raspberry Pi was already here last year, still running **NUT Server** and talking to multiple UPS units over USB (all the USB cables you see plugged in).
- The goal is a controlled, coordinated shutdown (instead of hoping everything survives).

![Raspberry Pi NUT Server](/assets/img/posts/homelab-2026/homelab-2026-raspberry-pi-nut-server.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APJfiBrl1qOvWNhpMVho+lwePbzwHew3Wi+HPFFppOn6xqOv+F7ufw34c8VaJrOgRXWqXNrDqGr3yw6ZqlzBLPpZ1CTTM2U36pxTg6tOrSr0504xpU+StHkTnWdrQ99Qi+RWk3CXMm5Nu7Vz4TJcwp1nPDVqc+ZTn7FwnJQiot885Rc2nUlzcqcYr3YxV97/AJj+IP2rtc8I69rfhSL4Y/C54vDGr6l4eiaHw3pUELR6LezaajRQW2k2ttDGVtgUit7W2gjUhIreGMLGvK51qbdPkwj5G4XdKV3yvlu7SSu7dEjKMcJViqnLiV7RKdva03bnXNa7pNu1+rb7tn//2Q==" }
_Raspberry Pi running NUT Server_

Small note: if you’re rotating SSH keys with Ansible, add the new key first, make sure you can log in, then remove the old one - ask me how I know 🤦.

### Backup DNS

- My **Pi Zero** was also here last year, still running **Pi-hole** as backup DNS if the rack is down.

![Raspberry Pi Zero Pi-hole](/assets/img/posts/homelab-2026/homelab-2026-raspberry-pi-zero-pi-hole.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/AOI/bN8QfFnx98Ffh98Tbj4pa14c1WL9nbwdq3ijQNAtktdF8Saxqtprl9f62biyn0trDUJJ/CWl+XFHpslpbwJ9ntI7YNLJL9xmWCpTxUlKMJwlGnGUJwU4ySrO0Zc13yxdSTWrd993b47Kswr4elQdGpUpTUq8vaUpunNP6tzJqUba3ppNKyak+yP5RdZs/Eeq6xqupz6jZyT6jqV9fzSSpM0jy3l1LcSPI2Dl2eQlzk5Yk5Ncf9nW0UopLRKzVktlZabHoSzlNtzpzlNtuUnJXlJu8pO7vdu7P//Z" }
_Pi Zero running Pi-hole for backup DNS_

### OTA TV

- An **HDHomeRun** provides over-the-air TV, connected into Plex for DVR/live TV.

![HDHomeRun](/assets/img/posts/homelab-2026/homelab-2026-hd-homerun.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APDvE/xU/ab8LeE/2fdet/iTo9ppnxD8BeO38efDfRNNOneDtX1bS9J0rRtIu3vLu11O6u0sbK2spPMn0qC5ka3ktS4jupbgfp2e4KFXFYHEyjTnOMKkveXI4P2LlVlCSU3KV4S5IySg00nyPVfn+VYv6phsfh71IJzowUoP2nNF1lGnCUZSpcsW5RdSUZcys7c+ql+c2q/tM/Hax1TUrJfHWr2a2d/eWotLHUB9itRb3EkQtrTZp9kn2WAJ5Vvss7RfKVNttAMRJ8pUwWCnUqTnRvOc5Sm97ylJuTu5Ju7b1sr72R9FSzTMYUqcKdflpwpwjTj8NoRilFWtK1opK13ba73P/9k=" }
_HDHomeRun for OTA TV_

### Wall power + battery backup

This whole wall is powered by power strips and backed up by a UPS, so all of this wall gear stays online when power flickers.

![Wall UPS](/assets/img/posts/homelab-2026/homelab-2026-wall-ups.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APov/gs7+zp8XbvStB8ReBPiL4I8M/C/T9N8Ja3FoOpfDvwnrPinQNY8Im50zVo9B1iTwsmqy+H9T8Paf4ZkTRZfFOnG417RreW8vl0+x0y2tcsvxWG9i6VWlWdadX2MOSrONKp7TW9b957vK1NJ06bdpu+7Ns1p1oqNSFSCoqClyunFzhKKs+R8t7Sjy3Up/FFN3srfMUvxx+EmiySaM3w2lum0l30xrq4sNMubi5awY2pnnuZdSEtxNMYvMlnkAkldmkcBmIrwJYetzO9azu7pN2Tv093bt5GSr0+lPTpff567n//Z" }
_Wall UPS keeping the wall gear online_

---

## Zigbee, IoT, and the "make dumb stuff smart" corner

A few highlights from the wall-side automation gear:

- **Broadlink**: used for RF control to make a dumb ceiling fan act smart (including "remembering" its last state via automation).
- **SMLIGHT (SLZB-06)**: running as my Zigbee coordinator, with ~80+ Zigbee devices (leak sensors, switches, motion sensors, etc.).
- **UniFi Sensor (test gear)**: a UniFi motion sensor I was testing.
- **UniFi SuperLink**: testing UniFi’s closed sensor ecosystem (environment sensor + motion sensor).
- **UniFi Siren**: PoE powered; I’d love to tie this into smoke alarm / alerting in the future.

![IoT Devices](/assets/img/posts/homelab-2026/homelab-2026-iot-devices.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APuv9lH9svxv4g+JPixnubu8t9F+G/hfx3pd1rWn6Ne6hDHpXxM+Kfg7WHnVY0S6vtSg8JXdxBBNcNHENWiiuNQnk0yK4n8mng8NGUKbpycpfWG5Kc0ounKnTvFKUU1L21NuFox92SioqyPoo5liKlOvjVyxpRpYSTpJK69q8X8PPzzelB/xK05XnfmfKrfpBo//AAU9uY9I0uPVfCdzqOqJp1impaga2FjpttfX620QvLy30463fnT4Lm4Ek8Vkb68NrG6wG7uDH5z98swoOUnCvNQbbinC7UW/dTftN0rJnnx4klyx5qMublXNZwtzW1totL7aLToj/9k=" }
_Zigbee, IoT, and the 'make dumb stuff smart' corner - Broadlink, SMLIGHT coordinator, UniFi sensors_

---

## The rack (network, storage, compute, and control)

### The core switch upgrade

#### UniFi USW Pro XG 48 PoE

The big upgrade on the network side.

- 48 ports total (mix of **10GbE** and **2.5GbE**)
- All PoE+++
- 25Gb uplink ports (I’m using multiple uplinks/LAG to the gateway)

It’s also the first UniFi switch I’ve owned where I can actually hear the fan under load - not super loud, just noticeable when it’s moving air.
![UniFi USW Pro XG 48 PoE - dark mode LEDs](/assets/img/posts/homelab-2026/homelab-2026-switch-darek-mode.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/AP5P/Hfxb0ex8UyW2qeFLa8FhrWoWrW8UdslkbaHVrrZbW0ES2cdnDFCVgQWUdmxWNSSpA2/0/xNxvkmC40xOWY/hPKMXhMLnmJwmMpxy/AQlXwcMdVpU6FLEUqGGxNN0qEvYwqQq0ZcsYtpTTk/Hw2B/wBgio4jExqSw0fZTVepeFZ01erLmc1O80puMoyfNze9ZqK+Z9V+IesHVNSNkJLKyN/eG0s4r/UfKtLU3Eht7aPfdSP5cEWyJN0kjbUG53OWPwOL8SMyw+KxOHwFKphsDQxFajgsOsyzZKhhKVSUMPRSjmCilSoxhBKPurl00O6lhafs6ftJSqVOSHPNxhec+Vc03ZJXlK7dklrokf/Z" }
_USW Pro XG 48 PoE with dark-mode LEDs_

![UniFi USW Pro XG 48 PoE - light mode LEDs](/assets/img/posts/homelab-2026/homelab-2026-switch-light-mode.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APwY+J/7RPw0+Gll8FvDPj34QaT4vt1+HfwNuLyS1sNCin1HS/E3wo8B+IdShuNUgs9E8RRXl7q2t6pqVxNba3FIs92IhdSmH7VN+gYHMMvwlLLsLi8BGvHEQw8qs4U8Oqjp1E4SiqihSxClo2m8RKKd7xkpNLxMRl8sRHEYiOIxFOpCWIjSUcViFTjUjNyjJ0ZTq4ZxVrOKw92kveT1Py78fftTa5a+O/Gtt4P0GXw/4St/FviODwtoMfjj4mpHonhyLWLyPRNIjQeOLgImm6YtrZKouJwqwgedLje2WI4phha9fDUcBN0cNWqUKTnmeZxk6dGcqcHKNPFxpxk4xV1CKgndRSVkc2Gyz2uHoVK9eLrVKNKdZxwWBcXVnCMqji5YfmcXNuzl71t9T//Z" }
_USW Pro XG 48 PoE with standard LED lighting_

### Gateway + core uplinks

#### UniFi EFG (25Gb gateway)

This is my core gateway and it’s way more than I need, but it gives me tons of headroom.

One reason this does make sense for my setup is that I can keep IDS/IPS turned on and still push around ~13 Gb/s, so I’m not forced to pick between security features and performance.

#### USW Pro XG Aggregation (25Gb)

This is the core aggregation switch upgrade that ties the backbone together and lets me build out faster uplinks through the rack. It’s also where all of my **10G links from the servers** connect, and it’ll be a great down the road if/when I run **fiber through the house**.

![USW Pro XG Aggregation Switch](/assets/img/posts/homelab-2026/homelab-2026-aggregation-switch.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APy80n9vPUPiN8SPC3w98OalrPhnT9W8a6D4budej+FPwjN9aC81bTUv9SisNQ/4SDU7xIdO1SAwaWnjPSrm7uhcwt4g0+Dy5n/WpZXLD4uGJUo1fac0nCrVxMlPmjOKUlGcYR1T1VOXJ7rSk1Y+XlnXt8NKmlOEY6c0aOGjJOLi5SScZylo1Ze0jzapyinc9o+Jv7YHiTwf8SfiD4RTxT40KeFvHHizw4htdC8Ei1K6Jr1/pim2F5FdXYgItQYRdXNxciPaJ55pd0jeNicJjfrOI9njOWHt6vJFwp6Q9pLlWtKT0VlrKT7ye548IYicIT/tXH0uaEZeyhh8unCnzJP2cJVMM5yhC/LGU/faSctWz//Z" }
_USW Pro XG Aggregation - 25Gb backbone connecting all servers_

### Remote power + clean cable paths

- **USB PDU Pro**: makes it easy to power-cycle individual devices remotely.
- I’m still working on cable cleanup - brush panels, cable routing, and making the front of the rack as clean as possible while still making efficient use of the space I have.

![UniFi PDU Pro](/assets/img/posts/homelab-2026/homelab-2026-unifi-pdu-pro.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/AOM/a2/bx0/4YeKviP8AD3wv4Z8S6146+H/iLxP4VsviH4ku/D9po1vPo+n2MMsumeBtG05NTNrp8t9bNbrrPxB1ZvEH2Sb7fFo9rexafp3uYXBYt4rD4mGK9jhKjo4iOFhOo6ns5y5lCpXdoOThFx/d4emqfu8l3Hme+KzHDww9fDyoOtXowq0J16sKPJKpGHLKcKPK5xjzSUrTrzlUalzuKlyx+jLL4QXniqztPFEHxO1iaDxJawa9DLd+DNJsrqWLWIk1COS5sz4h1s2lw6XAaa2OtauYJC0X9qX+z7XL9VT4fpYiEK/tvZe2hGr7JUqVRU/aJT9mqjhTdRQ5uXn9nT57c3JG/KvgsRj8ypYivSp5jiPZ061WnD93hI+5Ccox92WGrSjol7sq1WS2dSo/ef8A/9k=" }
_UniFi PDU Pro for remote power cycling and individual outlet management_

---

## Storage + cameras (keep it local)

### UniFi UNVR (local Protect recordings)

My camera footage stays local on the **UNVR**.

It’s set up with four 8TB drives in RAID 5. I can get about 2 months of 24/7 recordings on 12 cameras.  I love Protect and not relying on the cloud.

### UPS strategy

I split UPS power into two buckets - networking and servers.

#### 1U Eaton UPS (networking + PoE)

The 1U Eaton UPS is dedicated to all of the networking gear, so my network can stay up independently from my servers.

It also backs up the PoE switch, which keeps a lot of devices around the house online during an outage - access points, cameras, other switches, and more.

![1U Eaton UPS](/assets/img/posts/homelab-2026/homelab-2026-1u-ups.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APw8/a38cfFrRPF2s3mp+I/C2v8AgiG10i80HQPE/gnw/wCM77w3b6hY+Hb0JoOo69p66losy32pSTEabrMECGS6eJAZwie1Wj7TE0Grrlo4OK1trToxp9YyVrwb1Utk2vsrgw7ccFJNrl58RJ2im+Wdao7XutbS1acfW65n+lEP7Ld78QIYvHmr6pBfat42ij8Xape3mu3y3l5qPiRRrN7dXaweHPIW5uLm9llnEP7oSuwj+TFfc4vA1pYrEydaScsRWbSq1LJupJ2XLGEbLpywgu0YrRfDYbHUqOHw9GFL3KVClTheEG+WFOMY3cpTk3ZK7lOUu8pPV//Z" }
_1U Eaton UPS - dedicated networking and PoE backup_

#### Tripp Lite UPS + battery extension (servers)

The big UPS at the bottom powers the servers.

It’s a Tripp Lite with an external battery pack, and I typically see anywhere from ~60 to 100 minutes of runtime depending on the load.

![Tripp Lite UPS with Battery Extender](/assets/img/posts/homelab-2026/homelab-2026-tripp-lite-ups-with-battery-extender.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APlj9gHV/wBqL4M6fe6lcfF3w2PCMCx69ca1qfhST4teN7LTWtINK/sbTdL8Y3XhrQrixcxSSwWt3q0P9nTNNcrd3rXggsfch7SCh7WUZwtzqKhG9/azg7vlTetNu974IvWySTtex5SOE1ZvrLlX3pLXbu9D/9k=" }
_Tripp Lite UPS with external battery pack_

![Tripp Lite UPS Runtime Reading](/assets/img/posts/homelab-2026/homelab-2026-tripp-lite-ups-reading.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/AOE0342fHXxlrnwG1f4Mn4TaLpP7Nmk+HfDFzpnxG8I6prusz6lpes6r4j1jUPDHiI6vrtjp0N1D4juYtMEHhXRp7SfBkZzHHcD9EeZVpYCWGjL/AGWnKXtqVSMpKUpQ+r1ZU4wrUqbm6KcYVKsJTg2mn7kUvhfYfVsTJpU41a9SE/axjGU5ULwqypOUoxqUm2rL2dR01a7hJOUZeIap+z78U9T1PUdSstc8Gx2eoX13fWkdxf60k6W13cSTwJOsfh2WNZlikRZFSWVA4YLI64Y/G+6tHzX62sfoVLDYmVKnJTpWlTg1dyvZxTV/c37n/9k=" }
_Tripp Lite UPS display showing estimated runtime_

---

## Proxmox cluster (compute + Kubernetes)

I’m still running a Proxmox cluster on a set of Intel NUCs.

- Clustered for a single pane of glass and easy migrations
- Kubernetes nodes inside Proxmox (plus VMs/LXCs for various workloads)

![Proxmox NUC Cluster](/assets/img/posts/homelab-2026/homelab-2026-nuc-cluster.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APwlv9J+KfxmX4fNF8U7/wAL6J468eXXwb0zTLNPEIt9KuvBmpeFbu3vL3TdN8VaTY31rNH42O6+jaC/dbFbF7X7OLOay/Q6eT1s2qYXERxMKKp1q+EoqUaknGWHj9ad+WcUoONRxjJe9dKPKoWt8dDMKGBp46j9XnNqjRxdeSqRip/WObD+7Fwa5r0LyUly+9zayck/y88QftF/E7xDr2t6/qXiC6bUdc1fUtYv2tybW3a91O8mvbowWsLrDbQmeeQxQRKsUKbY4wFUCvmJ5lOrOdSfM51JynNqyTlNuUmlfRXbsj6ajgsNRo0qMKdoUqVOnBNp+7CCjHXl7JH/2Q==" }
_Intel NUC Proxmox cluster - running Kubernetes and various workloads_

---

## JetKVM row (remote console)

A whole row of **JetKVMs** gives me remote keyboard/video/mouse access over the network.

I have six of them in the rack, and they’re connected to six machines so I can get console access without dragging a monitor and keyboard around.

![JetKVM Row](/assets/img/posts/homelab-2026/homelab-2026-jet-kvm.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/AORstV+KHxbm1Cx17xnqUI07VRJp+rXXibxLrmqWslv5ukHUDYyTaV4bvrq50iy02RItZ0bVJbLUm1We41PWJNRnuX/m2rxZgssio5fllSrXqqLnVxuIUaMqj96o1hsHGhyR9vKcoL204qCpx9muV3/odcJYnFvmxmZRpUKTkqdHBYde1UEuSClicXKvzS9jGEJtUIScueTqPmPqO08T3Nta21teMuq3lvbwwXWqXVhYRXOpXMUaxz39xFaJDaxT3kqtcTR20MVukkjLDFHGFUfFzx3POcrOnzSlLkpp+zhdt8kOao3yRvaN23ypX1PpI4RQjGHx8sVHnqNOc+VW5ptQs5yteTWl2z//2Q==" }
_Six JetKVMs for remote console access to rack machines_

---

## UniFi AI + controller

### AI Key + AI Port

- **AI Key**: adds smarter detections and summaries on top of Protect events (classify/describe/transcribe).
- **AI Port**: enables AI events on older or third-party cameras that can’t do it natively.

### UniFi Cloud Key (controller)

An older Cloud Key I keep around for testing other UniFi apps (since the EFG only runs the UniFi Network App). The drive died, so I swapped it to an SSD.

---

## Mini test box

### Beelink EQ14

My small "test box" for containers - especially when I need to test Intel QuickSync.

![3D Printed Rack with AI Key and Beelink EQ14](/assets/img/posts/homelab-2026/homelab-2026-3d-printed-rack-ai-key-beelink-eq-14.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APiu08Nn4yeMvjR4Y0XVdU8GaD8DfEmp2Vpobax4t1CO5sx8UY/g5p88Or6R4s8L3N1qH2GObUXn1axuZdOso4fD1lcy29xJf2/6nOjhp1MDjK9ONWpiaVB14+xpQhP2tOnV0j7yguafvRirNxUtW3b5+g61aOLw1OpOjGhVrKjarVlyRp15YdOT5oyqT5ILWTTSbhflWv8ATt8Bv2dPhlb/AAN+DMCafdOkHwo+HcKvPcz3U7LH4Q0dFaa6up5rm5lYKDJPcTSzzOTJNLJIzMflsVn+NjisTGlGnClGvWVOLV3GmqklCLaSV1Gy00PqMLw5g5YXDSnKcpyw9FylrrJ04uT1k3q7vVv1P//Z" }
_3D-printed rack housing the UniFi AI Key and Beelink EQ14_

---

## Storage testing

### UniFi UNAS Pro 4 (video coming soon)

I’ve been testing this device for a long time, and I’ll show how I’m using it in a future video.

It’s loaded with four 20TB drives in RAID 5.

---

## One shelf (GPU + mini boxes)

These three live together on a shelf:

- **MinisForum MS-A1** + **RTX 3090 (Oculink)**: used for testing that needs a dedicated GPU (including local AI testing/tutorials).
- **Beelink ME Mini**: all-NVMe box that I like more as an app/Proxmox/LXC server than a traditional NAS.
- **Beelink ME Pro**: a quiet hybrid mini NAS (NVMe + SATA) in an all meta case.

If I ever had to _shrink_ the homelab, it’d probably come down to "bulk storage + app server + one flexible compute box," and these smaller systems have been great for testing that idea.

![Beelink ME Mini](/assets/img/posts/homelab-2026/homelab-2026-beelink-me-mini.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APxo+DX/AATrsPBMXwpsfDun+D/+E/0f4q3viDxL8Q9b8VeK9YXxV4FPh69Fl4IufBa+HrDw9aSWOvrpuq2+u2JtdSRbaVDO5fa341hOPcHXxFV51lrxdGr/AA6MKNCrTow9jGMoKnWqw5/aWnOUqlSUk58sHCKsf1pmnhtVwGWYWjwXn2Ly3EYVqrjK+KdbDV8xrvFVZ06tXE4OvXjRVCnVp0adHDYSjTnGkp1/aVZOo/T/ABL/AMEbtF8SeI/EHiK4/aE1exuNe1vVdansrT4Y6abS0m1S/nvpbW1P/CZwZt7d52ihPkw/u0X91H9weRPi2CnNUcuiqSlJUlOtLnVNN8ildT95Rtze/PW/vS3f3FCeYwoUYV8Yp14Uqca04wXLOrGCVSUdIe7KabXuQ0fwx2X/2Q==" }
_Beelink ME Mini - all-NVMe compact server_

![Beelink ME Pro](/assets/img/posts/homelab-2026/homelab-2026-beelink-me-pro.jpog.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/AOX8L/AGG7+IGmQeFbq8h+C8Xh7+2Na8Ka34ouW8Xtp2g29cutafpviCHwze2f2zXJ5re3tdRns410aG7uL5bO+m0yGy1T8+wXilXp5fi6WZ0HWzGLlRoYrDYaiqEJ15yjRrToTxFOU1QjGTlS517SSj+8gpPl/XMb4U4eri8LUy2tClgW1VrUMTia7xEqdKN6tKNaGHnG9WUoqNRw/dpuThNxUZfm94ut/hJp3izxPp7/CHxiz2HiLWrN2i/aEj8tmtdSuYGMfmfAYybCUJTzCX243Etk1v/r7mEvep4pOnL3qbqZNQjNwesHOMc0nGM3G3NGMpRTulJrV3Dw1ylRiq0KyrKKVVUsfOdNVElzqnKeChKUFK6hKUIScbNxi20v8A/9k=" }
_Beelink ME Pro - quiet hybrid mini NAS (NVMe + SATA)_

---

## 1U Supermicro server (new build, video coming soon)

This is a "new to me" 1U Supermicro server. It’s older hardware, but it checked all the boxes I needed: 1U, lots of drive bays, and IPMI.

It’s running an **Intel Xeon E5-2680 v4**, has 16GB DDR4, and four 22TB Exos drives.

---

## Storinator (big plans)

This is the **45Drives Storinator AV60**. Right now it’s powered off, but it’s one of the bigger "next steps" in the rack.

The plan is to rebuild it around an **EPYC** CPU that **Wendell** sent me, but I’ve been holding off because DDR5 (and the board I want) has been hard to justify and hard to find.

As soon as the parts situation calms down, I’m going to gut it and bring it back online.

![Storinator AV60](/assets/img/posts/homelab-2026/homelab-2026-storinator-av60.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APmD9qH4R6/onxx8f+J9J+IHxAtfDfjHUrrxBcSWXxS+IGk63Ho/i2SLxbD4eGlWmoS6ekNtphi0ueQa1JbPdI14tg2LdLf+k8Bw7gs6pYCeFoUaEKWCpxr06zqpSxGHwTp1VSVKThHDzxdCpWp8sKc40pRp2TvJfm2KzmllE60sdWx1T2tepUVXDU8PUm44isqmGVSNapRcpRhUhSrzlWm3aU48zaifeXw8/Yks9b8AeBtavPFvi+W71fwd4Z1S6lb4t/FjdJc3+i2V3PI2ddc7nllZjl3OTyzdT3YrN+GMuxOIy+rwZga9XA16uDq145jjYRrVMNUlRnVjGXPKMakoOajKc5JOzlJq648Jlmc4/C4bHUuJ8bSpY3D0cXTpywGBcqcMTTjWhCTjHlcoRmou2l1pof/Z" }
_Storinator AV60 - future EPYC rebuild_

---

## 45Drives HL15 (all-in-one TrueNAS refresh)

My **HL15** has changed a lot this year.

The goal was to build a better all-in-one system (since new builds and parts are annoying right now), so I upgraded this box pretty heavily:

- **10x 14TB drives** for bulk storage
- **256GB DDR** (slots are maxed out)
- A better CPU (a Platinum upgrade from Patrick at [Serve The Home](https://www.servethehome.com))
- **Noctua 120mm fans**, a **Noctua Xeon cooler**, and a **Seasonic PRIME 1600W Noctua Edition PSU**
- More NVMe (including adapters to convert M.2 to U.2, and Oculink into PCIe lanes)
- An **NVIDIA RTX A2000** inside the chassis for the workloads that need it

It’s running **TrueNAS** with **ZFS**. Right now it’s set up as mirrored pairs, but I’m planning to revisit the ZFS layout to trade some IOPS for more usable capacity and resiliency.

![HL15 with 45 Drives](/assets/img/posts/homelab-2026/homelab-2026-hl15-45-drives.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APhL9t346/Dr4Yn9knTbnwZreu6vq/7PPwC1PRrMXUNrYweILnQbSbWtUl8R3WqalqGlG/u3tZIotO8P3MdvB9ogiSOMQqv7PT4i/s/LOH6cOedZ0LKnPCYOdCMqeLqQ51VrKrUcqtHlpykqUXTs7c8HyL86w2CqV6+be9KFOnjKSkqcb2S1t+6bVopvfVr3XuzVS1/gS0f4v8A2ddS/Y9fxB8cbuKHw5L4r/aOXxzqFp4J+Gfi241OX4hW/wAGmhu7n7C2hWdreGS1vLq7soXtluJbO5sbS1uo3tbuF/nPFVYLOMwrRipTjDERUWnG3Lh6UWlJq6UnC+1/ef8AXpbAAAAAAAAAAAAAAAAAA/9k=" }
_HL15 loaded with drives for bulk storage, GPU, and NVMe_

![HL15 All Slots Filled - Overhead View](/assets/img/posts/homelab-2026/homelab-2026-hl15-overhead-all-slots-are-filled.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APm3SvBF1qviC68a2PjD4geH9d1DV4W0s+HPHep6JpUWl6Hr2p6r4T0O80W2sJLMWKz67AdcmjM97Ium6fDp1xbLp1u7/kfDdSX/ABD7O5ycoV6WE4hpudNp+1lHCStUqVJr2nNCspSpuHIox5Xy8yP0zN6UIcb5M4xU8PLEZFUlTqXSinioSqRhSg1SmqlG0Je1525c1nFNt+pReM7iyijs7+S4vL60jS1vbtzPO91dwKIri5eeXUY5ZmnmR5WlkRJJCxd0ViQPy3C5LiJ4bDydSleVClJ/vKu7pxf/AD7ffuz9HxOa01icQoKpGHt6vLFU6fux9pLlj/E6KyP/2Q==" }
_HL15 overhead view - all RAM slots filled_

---

## Backup internet (5G)

I’m using **T-Mobile Home Internet over 5G** as my backup link, and it’s already saved me a few times during outages.

The annoying part is that the SIM is locked to their gateway, which makes it impossible to use with the **UniFi 5G Max**.  I really hope T-Mobile allows this or UniFi comes up with a way for us to use T-Mobile Home Internet with this device.

![UniFi 5G Max with T-Mobile SIM](/assets/img/posts/homelab-2026/homelab-2026-unifi-5gmax-tmobile-sim-5g.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/ALPxU/a6079pj4kftd+N9SuvG2heC7n4Jap4c0Hwn4a0bwx4Hbw9rmj+OPHmlan4lsJPDOrG6t9VvNHTQI4NYs9ZtdcWXS5IpL8Q3VxJP+xxoN0q1GWIxFX2WDVOftqk5yjKPPz1aVapOrU55ONotqKiuj0Ufi8PVpwVaqsPRpxnGToqnCK5WrWU6cVTiopS2jNvonGzcvxb0D9oTW9M0LRdOsdW8YGy0/SdOsrM3+vajf3xtbSzhgtzeX0uqrJe3flRp9ou5FV7ibfM4DORXgRnFRirN2ildttuy3b5tX3fVmvtJvXTXXot/Ll0P//Z" }
_UniFi 5G Max with T-Mobile SIM as backup internet_

---

## What’s next

I’ll have a video soon on how I back up my servers.

I’ve also got another video coming that walks through the services running on all of these machines, and how I spread workloads across the rack.

---

## 📦 Gear list (affiliate)

### Rack & Accessories

- [32u Rack](https://amzn.to/3TlhdXb)
- [1u Brush Panels](https://amzn.to/3hKNiaf)
- [1u Rack Mount Full Depth Shelf](https://amzn.to/3jrm5Kp)
- [Right Angle Extension Cord](https://amzn.to/3Wl7gay)
- [UniFi Power Distribution Pro](https://l.technotim.com/unifi-power-tech)

### Network

- [Patch Panel](https://amzn.to/3YIKtHq)
- [Wall Mount Patch Panel](https://amzn.to/3WyvnCk)
- [UniFI EFG](https://l.technotim.com/unifi-gateways)
- [UniFi Flex Mini](https://l.technotim.com/unifi-switches)
- [UniFi Flex 2.5 Mini](https://l.technotim.com/unifi-switches)
- [UniFi Fortress Gateway](https://l.technotim.com/unifi-gateways)
- [UniFi Pro XG 48 PoE](https://l.technotim.com/unifi-switches)
- [UniFi USW Pro XG Aggregation](https://l.technotim.com/unifi-switches)

### Servers & Accessories

- [UniFi UNAS Pro 4](https://l.technotim.com/unifi-network-storage)
- [UniFi UNVR](https://l.technotim.com/unifi-nvr)
- [MinisForum MS-A1](https://amzn.to/3W6HMja)
- [Beelink EQ 14](https://amzn.to/4c66WYd)
- [HL15](https://store.45homelab.com/configure/hl15)
- [14 TB Exos Seagate Drives](https://amzn.to/3GbtXsk)
- [20 TB Exos Seagate Drives](https://amzn.to/4s3xrC2)
- [22 TB Exos Seagate Drives](https://amzn.to/4tS9iQH)
- [Noctua 120mm fans](https://amzn.to/4aU6rOy)
- [Seasonic PRIME 1600W Noctua Edition PSU](https://amzn.to/4rzXpgJ)
- [Noctua NH-U12S DX-4677 for Xeon](https://amzn.to/4bcmPv2)
- [NVIDIA RTX A2000](https://amzn.to/4qWJLDa)

### IoT & Sensors

- [UniFi SuperLink](https://l.technotim.com/unifi-superlink)
- [UniFi Sensor (motion)](https://l.technotim.com/unifi-superlink)
- [UniFi Sensor (environment)](https://l.technotim.com/unifi-superlink)
- [UniFi Siren](https://l.technotim.com/unifi-superlink)
- [Broadlink RM4 Pro](https://amzn.to/4l2AcSc)
- [PoE Zigbee Adapter SMLIGHT SLZB-06](https://amzn.to/4kS8iYW)
- [Smart ZigBee LED Controller](https://amzn.to/3jtCpKI)
- [Hue Light Strip](https://amzn.to/3I124o3)
- [Hue Motion & Temp](https://amzn.to/3qb1FXf)
- [Hue Smart Bulb Starter Kit](https://amzn.to/3jljCRA)
- [Cloud Lamp](https://amzn.to/3GZji24)

### Other gear mentioned

- [JetKVM](https://jetkvm.com/)
- [UniFi AI Key](https://l.technotim.com/unifi-nvr)
- [UniFi AI Port](https://l.technotim.com/unifi-nvr)
- [UniFi Cloud Key+](https://l.technotim.com/unifi-nvr)
- [UniFi Talk Phone](https://l.technotim.com/unifi-voip)
- [UniFi 5G Max](https://l.technotim.com/unifi-internet)
- [Raspberry Pi (NUT Server)](https://amzn.to/4rxADWQ)
- [Raspberry Pi Zero (Pi-hole)](https://amzn.to/4tYvwR5)

### Accessories

- [Wall Control Galvanized Steel Pegboard](https://amzn.to/3bJ8R4s)
- [Eaton 5P1500R UPS](https://amzn.to/3OC2D90)
- [Tripp Lite 2200VA 1920W UPS Smart 2U Rackmount](https://amzn.to/3XrnC2q)
- [Tripp Lite BP36V15-2U Smart UPS 36V 2U Rackmount External Battery Pack](https://amzn.to/3XxwBzd)
- [APC 1500VA UPS](https://amzn.to/3GXLJh6)
- [APC 600 VA UPS](https://amzn.to/3mMxsM1)
- [Wall Power Strip](https://amzn.to/4ucw4mK)
- [Fire Extinguisher](https://amzn.to/3GeB2s4)

### Over the Air TV Gear

- [HDHomeRun Network Tuner](https://amzn.to/3Gdkd0x)
- [TV Tuner that supports 4K and up to 4 streams](https://amzn.to/3r1v3SL)
- [Indoor Outdoor Antenna](https://amzn.to/3sHLST3)
- [LTE / 5G Filter](https://amzn.to/3Pax72J)
- [Antenna Splitter with Passthrough](https://amzn.to/3sLTZy4)

### Intel NUC Mini Cluster

- [Intel NUC 11](https://amzn.to/43TK8nS)
- [Intel NUC 12](https://amzn.to/3OGjXOi)
- [SAMSUNG 980 PRO SSD 1TB PCIe NVMe](https://amzn.to/4b1p1FL)
- [SAMSUNG 870 EVO SATA](https://amzn.to/4kQ7BPL)
- [G.Skill RipJaws DDR4 SO-DIMM Series 32GB](https://amzn.to/4kUcJlS)
- [Rackmount Kit Mk1 Manufacturing](https://www.mk1manufacturing.com/cart.php)

(Affiliate links may be included in this post. I may receive a small commission at no cost to you.)

---

🤝 Support the channel and [help keep this site ad-free](/sponsor)

🛍️ Check out all merch: <https://shop.technotim.com/>
