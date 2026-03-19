---
layout: post
title: "What I'm Running in My Homelab in 2026"
date: 2026-03-15 08:00:00 -0500
categories: homelab
tags: homelab self-hosting proxmox truenas kubernetes docker plex homeassistant pihole traefik grafana paperless ollama immich
image:
  path: /assets/img/headers/homelab-services-tour-2026-hero.webp
  lqip: data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAUACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/AP5sPDfxF8JaPo2h6bffs/8AwW8UNofhfVoBqPiG8+O5vdYvLqWxX+29aj0P456Hph1a1Oj3TWkWiaboXh5v7f1c6l4f1KRdMk07swWNqYtLlniMPVnmFHD89PENU5TlLAOvWq04wpyr+2deEZQqVW3TpeyqzrUpuCyzTB0cFiWp06OKUMPKb9rSjKXs6dPG1aVKm6jqxpck6U5c0IW56sqkIU5xUj54uPENhPcTzxaHHp0c00ssen6dqN2NPsUkdnSzsRqQ1PURZ2qkQWv2/UtQvfIRPtV9dz+ZPJ68Mfi4QjCM6bUIxgnJVnJqKSTk1iEm7LVpK76IieQ5fOUpzljOeUnKfJWoQhzSbcuSDws3GN2+WLnJxVk5Std//9k=
---

In my last homelab tour, I focused on the hardware.

This time, I wanted to answer the question a lot of people asked after that video: what am I actually running on all of this infrastructure?

So this is the software side of the lab in 2026. The services, the applications, and the systems that make the hardware useful.

Some of this is practical. Some of it is for learning. Some of it replaces tools I would otherwise pay for. And some of it is simply because I enjoy self-hosting.

{% include embed/youtube.html id='efl2kuPNEpE' %}
[Watch the video](https://www.youtube.com/watch?v=efl2kuPNEpE)

---

## The basic shape of the lab

At a high level, I am running three main layers:

- [**Proxmox VE**](https://github.com/proxmox)
- [**TrueNAS**](https://github.com/truenas)
- [**Kubernetes**](https://github.com/kubernetes/kubernetes)

It is a fairly broad setup, but it has settled into a structure that makes sense for how I use the lab.

At home, I keep most of my internal services close to the data. In practice, that means many applications now live directly on TrueNAS with [**Docker Compose**](https://github.com/docker/compose).

For public-facing services and the workloads I want to run in a more orchestrated way, I place those in Kubernetes in my co-location environment.

That split has worked well for me:

- **Home services**: Docker on TrueNAS
- **Public services**: Kubernetes in co-location

It keeps the home side simpler while still giving me room to run more distributed workloads where it makes sense and to keep my Kubernetes skills sharp.

---

## Network first

Everything starts with the network.

I simplified the network quite a bit this year. I used to have more VLANS which added more complexity. I scaled them back a bit to a network that is easier to maintain and easier to reason about.

My main VLANs are:

- **Main**
- **IoT**
- **Cameras**
- **Management**, depending on how you count it

My trusted devices live on main. Laptops, workstations, phones, Apple TVs, HomePods,and my NAS.

I put my HomePods and Apple TVs on this network because it's much easier (and safer I believe) than trying to create dozens of firewall rules from Main to IoT that I could mess up.

IoT contains the devices I do not fully trust or do not want sharing the same space as my main devices. Lights, thermostats, and similar devices go there.

Cameras are on their own VLAN, which makes sense both from a security standpoint and from a traffic standpoint.

One thing I have to tell myself over and over is that secure does not always mean complicated. A simpler network that I understand is way better than a more elaborate design that becomes difficult to maintain.

---

## Co-location

I also have a few servers running in a co-location. These are 1u servers that I use to run at home.

I moved them there because some of my public-facing services outgrew being hosted at home. After enough traffic hit my documentation site, it became clear that I should move that kind of workload out of the house from both a security and reliability standpoint.

So now I have a few machines there, still on hardware I own, still running services I manage, just with better power, better network, and more separation from my homelab.

There is also a VPN between home and co-location, which makes management and backups easier.

That setup has been a good middle ground between running everything at home and moving everything into the cloud.

---

## Of course, I am still using Proxmox

I am still running Proxmox, and I do not expect that to change anytime soon.  It's great and does everything I want, except native OCI containers (but don't get me started on that)

At home I have a three-node cluster, and I have another three-node cluster in my co-location. I am not clustering Proxmox because I want Proxmox itself to be the HA, I am clustering it because I want:

- one pane of glass
- easier migrations
- easier backups

That is really all I need.  One day if I get a faster network or just want to play with Ceph I will reconsider.

I am not doing HA VMs or HA LXCs in the Proxmox sense. I would rather push high availability down into the service layer itself.

So instead making a VM is highly available, I would rather run three Postgres nodes on LXC, or three Kubernetes control-plane nodes, or redundant DNS, and let the application or platform handle failure the way it was designed to.

This approach better aligns to the way I build and manage systems outside of my homelab.

---

## TrueNAS became more than storage

One of the bigger changes this year is that TrueNAS stopped being just storage and became more like my home production box.  "Home Prod" is what I have been calling it.

It is still where my data lives. ZFS, datasets, shares, snapshots, and replication are still at the core of the system.

But now it is also where many of my applications live.

Once I found out I could use Docker Compose on TrueNAS, I went all in and migrated all of my apps to this pattern. Now that I run my apps on TrueNAS, I can keep app data local, manage it with ZFS, snapshot it, replicate it, and roll it back the same way I do with the rest of my data.

That has a few advantages:

- app data stays local to the machine
- I am not moving everything over NFS and all of the headaches that come along with that
- snapshots are easy
- replication is easy
- my operational model stays consistent

It is one of the changes that made my NAS feel much more useful.

---

## How I think about Docker vs Kubernetes

I get asked this a lot.

For me, the answer is fairly simple:

- **Docker Compose on TrueNAS** for home services
- **Kubernetes** for public services and orchestrated workloads

That is not because Kubernetes is better at everything. It is because not everything benefits from Kubernetes.

A lot of services at home just need to run reliably, store some data, sit behind a reverse proxy, and be easy to back up. Docker Compose is well suited for that.

Kubernetes still makes sense for the workloads where I want a more cloud-native setup, a better GitOps flow, or more flexibility around placement and scaling.

You can absolutely run everything in Kubernetes if you want to. I just do not think that automatically improves the outcome.

---

## The services I use most often

There are a few services that I use.

### [Homepage](https://github.com/gethomepage/homepage)

I still use Homepage as my main dashboard.

At this point it is less about live status and more about organization. I like that it is YAML driven, simple, and easy to manage as configuration.

It has effectively become my launch point for the rest of the services in my homelab.

### [LittleLinkServer](https://github.com/timothystewart6/littlelink-server)

I also still use Little Link Server for all of my social links. It is simple, easy to configure, and does exactly what I need it to do.

### [Jekyll](https://github.com/jekyll/jekyll)

My documentation site and blog are still built with Jekyll. I have tried several static site generators over time, but I chose Jekyll this time because I really like the [Chirpy Theme](https://chirpy.cotes.page/).

### [Shlink](https://github.com/shlinkio/shlink)

I still use Shlink for link shortening and redirect control. It is one of those services that becomes more useful the longer you run it.

---

## The core infra

The services that make self-hosting are not always the most visible ones.

### [Traefik](https://github.com/traefik/traefik)

I am still using Traefik as my reverse proxy. It handles routing, certificates, and ingress for a large portion of what I run, both at home and in Kubernetes.

### [Pi-hole](https://github.com/pi-hole/pi-hole)

I still rely on Pi-hole for DNS and ad blocking, but I also use it heavily for local DNS. That becomes more important as my homelab.

### [Nebula Sync](https://github.com/lovelaze/nebula-sync) and [Keepalived](https://github.com/acassen/keepalived)

When you have multiple Pi-hole instances, you need a reliable way to keep them aligned. Nebula Sync handles the synchronization side, and Keepalived helps with failover.

One thing I changed this year was how I think about primary DNS. Most clients strongly prefer the primary until they absolutely cannot use it, so making the primary more resilient made things fail over much smoother.  

Previous to discover this I was made my secondary DNS HA.

---

## Monitoring and logging

This year I decided that if I depend on a service, I should monitor it properly.

So I leaned more heavily into:

- [**Prometheus**](https://github.com/prometheus/prometheus)
- [**Grafana**](https://github.com/grafana/grafana)
- [**Loki**](https://github.com/grafana/loki)
- [**Alloy**](https://github.com/grafana/alloy)
- [**Uptime Kuma**](https://github.com/louislam/uptime-kuma)
- **Uptime Robot** for external checks

That stack gives me a good mix of:

- metrics
- dashboards
- logs
- uptime checks
- internal visibility
- external visibility

This is one of the areas where self-hosting can become difficult quickly if you ignore it. It is easy to spin up an application. It is harder to notice when it is failing or throwing lots of errors.

I have also ended up relying on several exporters because many tools do not expose the metrics I want out of the box.

And for quick log visibility, [**Dozzle**](https://github.com/amir20/dozzle) is still very useful. Sometimes you do not need a full observability workflow and all you need at the moment is to see what a container is doing right now.

---

## Media

Media is still one of the largest categories in my homelab.

I still run Plex as my primary media server, but I also run [**Jellyfin**](https://github.com/jellyfin/jellyfin) against the same library. Part of that is comparison, and part of it is simply having an alternative ready.

If something changes with Plex someday, I do not want to be starting from zero.

I also run a number of companion tools around media:

- [**Tautulli**](https://github.com/Tautulli/Tautulli) for activity and stats
- [**Kometa**](https://github.com/Kometa-Team/Kometa) for collection and metadata automation
- [**HandBrake**](https://github.com/HandBrake/HandBrake) for re-encoding
- **HDHomeRun** for OTA TV into Plex
- [**ErsatzTV**](https://github.com/ErsatzTV/ErsatzTV) for virtual channels
- [**Dispatcharr**](https://github.com/Dispatcharr/Dispatcharr) to help feed multiple channel sources into Plex

The live TV and virtual channel side of things is one of the more interesting parts of my homelab. It is not the most essential thing I run, but it has been one of the more enjoyable areas to experiment with.

### [Immich](https://github.com/immich-app/immich), which I forgot to mention in the video

I also need to call out Immich because I accidentally skipped over it in my notes while recording and did not mention it in the video.

Immich is awesome.

I primarily use it for my good photos, mostly post-edit, rather than as a complete dump of every photo I take. That has worked out for me and it makes the library feel more intentional and more useful.

I also have a full tutorial on Immich here:

- [My Immich tutorial](/posts/immich-self-hosted/)

If you are looking for a self-hosted photo application, Immich is well worth a look.

---

## Documents

I have also become more serious about document handling.

[**Paperless-ngx**](https://github.com/paperless-ngx/paperless-ngx) is a big part of that. It is the kind of tool that becomes more useful the more real world paperwork you put through it.

On top of that I am also using:

- [**Paperless-GPT**](https://github.com/icereed/paperless-gpt)
- [**Apache Tika**](https://github.com/apache/tika)
- [**Gotenberg**](https://github.com/gotenberg/gotenberg)

That combination makes the Paperless much more useful than OCR alone. It turns it into something closer to a real document workflow.

I also run [**Stirling PDF**](https://github.com/Stirling-Tools/Stirling-PDF) for general PDF editing. it handles splitting, merging, and converting all within a clean web ui. I forgot to mention this in the video, as I did a few others due to the super long bulleted outline I was following.

---

## Visual tools

I am a visual learner, so I keep a few tools around that help me think through systems and explain them clearly, especially on video calls.

- [**Excalidraw**](https://github.com/excalidraw/excalidraw)
- [**draw.io**](https://github.com/jgraph/drawio)
- [**Rackula**](https://github.com/RackulaLives/Rackula)

Excalidraw is great when I want to explain something quickly without worrying much about precision.

draw.io is better when I want something more structured.

Rackula is useful and fun because it helps me diagram my rack and that saved me from running to the basement to see how things are set up.

---

## Automation

I run [**n8n**](https://github.com/n8n-io/n8n), and I think it is a very good tool however I don't have a need for a low-code solution right now.

I still like to write code for a lot of the automation I want, mostly because that's a big part of my day job.

I also tried [**Postiz**](https://github.com/gitroomhq/postiz-app) for scheduling social posts. It is useful, and I can see the value, especially for teams or for people planning content farther ahead than I usually do.

Since I am a small solo creator, I find this a little less useful than I originally thought it would be.

---

## Home Assistant

I am still running [**Home Assistant**](https://github.com/home-assistant/core), and if you have used it, you know it's quite the undertaking.

It is powerful, flexible, and worth the effort once you get it working the way you want.

Alongside it I am running:

- [**MQTT**](https://github.com/eclipse-mosquitto/mosquitto)
- [**Zigbee2MQTT**](https://github.com/Koenkk/zigbee2mqtt)
- [**Scrypted**](https://github.com/koush/scrypted)
- **UniFi Protect**

That gives me a flexible setup for home automation, cameras, and bridging devices into ecosystems they were not originally designed for.

Scrypted especially has been very useful in getting my Protect cameras into HomeKit.  It's great.

---

## Databases

A lot of the services I run need databases, so I end up running several of them.

Mainly:

- [**Postgres**](https://github.com/postgres/postgres)
- [**MariaDB**](https://github.com/MariaDB/server)
- [**Valkey**](https://github.com/valkey-io/valkey)

And because I do not always want to manage those from the terminal, I also keep a few admin tools around:

- [**Adminer**](https://github.com/vrana/adminer)
- [**phpMyAdmin**](https://github.com/phpmyadmin/phpmyadmin)
- [**dbgate**](https://github.com/dbgate/dbgate)
- [**pgAdmin**](https://github.com/pgadmin-org/pgadmin4)
- [**databasus**](https://github.com/databasus/databasus)

If working on a postgres DB, I always use pgAdmin.  But when it comes to MySQL-like DBs I usually reach for Adminer first because it is lightweight and does what I need without much overhead.

For backup and restores I am using databases.  It's an awesome tool to backup almost any type of DB.

---

## Local AI

It is 2026, so yes, I am also running local AI tools in my homelab.

The main pieces there are:

- [**Ollama**](https://github.com/ollama/ollama)
- [**Open WebUI**](https://github.com/open-webui/open-webui)

That gives me a local setup for pulling models, running them, and chatting with them without sending everything elsewhere.

I do not think every AI workflow needs to be local, the models just aren't good enough, but having a local option has been useful, especially when testing or experimenting.

---

## Kubernetes and platform operations

I am running three Kubernetes clusters and managing them with Rancher.

I mostly treat Rancher as the management layer, not the place where I make configuration changes. The actual workflow is still GitOps driven for me, with:

- [**Flux**](https://github.com/fluxcd/flux2)
- [**Renovate**](https://github.com/renovatebot/renovate)
- [**GitLab Runner**](https://github.com/gitlabhq/gitlab-runner)

That stack has been working well. I like defining things in Git, I like updates showing up as pull requests, and I like keeping the running environment close to what the repository says it should be.

There is still plenty of complexity in Kubernetes, but GitOps gives that complexity a structure.

There are also a few Kubernetes applications that did not really make it into the video because it was already too long, but they are important enough to mention here.

### [Longhorn](https://github.com/longhorn/longhorn)

I use Longhorn for cloud-native storage in Kubernetes. It is one of the pieces that becomes foundational once you start running more stateful workloads in the cluster.

### [Reflector](https://github.com/emberstack/kubernetes-reflector)

Reflector is useful for reflecting or duplicating secrets across namespaces. That simplifies secret management when the same values need to exist in more than one place.

### [kube-vip](https://github.com/kube-vip/kube-vip)

I use kube-vip for service load balancing and as a control-plane load balancer. It is a small component, but an important one.

### [Reloader](https://github.com/stakater/Reloader)

Reloader will automatically cycle services when secrets or configuration changes. That removes a lot of manual restarts.

---

## A few tools that make life easier

There are also a number of smaller tools that do not always fit neatly into one category but are still useful enough to keep around.

- [**Code Server**](https://github.com/coder/code-server) for editing from the browser
- [**IT-Tools**](https://github.com/CorentinTh/it-tools) for encoding, decoding, and general development utilities
- [**OpenSpeedTest**](https://github.com/openspeedtest/Speed-Test) for local bandwidth checks
- [**Scrutiny**](https://github.com/AnalogJ/scrutiny) for disk health
- [**nvtop**](https://github.com/Syllo/nvtop) for GPU visibility
- [**Netboot.xyz**](https://github.com/netbootxyz/netboot.xyz) for network installs
- [**NUT**](https://github.com/networkupstools/nut) and [**PeaNUT**](https://github.com/Brandawg93/PeaNUT) for UPS monitoring

### [Bambu Studio](https://docs.linuxserver.io/images/docker-bambustudio/)

One other thing that did not make it into the video is Bambu Studio.

I am actually self-hosting it, which is a little jank inside a container, but I have been testing it out. I keep it around for the times when I need to print something and do not have access to my main machine.

It is not the cleanest setup, but it has been useful enough that I keep it running in my homelab.

---

## The main theme this year

If I had to summarize the software side of my homelab this year, it would be this:

I am trying to make it more intentional.

Less "spin things up because I can."
More "put things where they make sense, monitor them properly, back them up, and make them easy to operate."

That does not mean the lab is simple now. It definitely is not.

But it does feel more cohesive.

More of the services have a reason to exist.
More of the architecture choices feel deliberate.
More of the setup feels like something I can actually operate without constantly rebuilding it.

That is probably the biggest difference from previous years.

---

## What is next

The follow-up from here is backups.

How I back things up, where they land, what I replicate, what I do not, and how I think about recovery is probably the next important piece to show.

Running a lot of services is one thing.

Restoring them cleanly when something breaks is another.

---

## Final thoughts

This is what I am running right now, not necessarily what I would recommend every person run.

Some of this is more than most people need.
Some of it is experimentation.
Some of it is simply what happens when a homelab evolves over time.

But I hope it gives you some useful ideas.

Not just for specific tools, but for how to think about the split between home services, public services, storage, orchestration, monitoring, and the operational details in between.

If there is one self-hosted service you absolutely cannot live without, I would be interested to hear what it is.

---

## Related

- [My 2026 Homelab Tour (Rack + Servers + Network + Storage)](/posts/homelab-hardware-tour-2026/)
- [My Immich tutorial](/posts/immich-self-hosted/)
- [Self-Hosted Paperless-ngx + Local AI](/posts/paperless-ngx-local-ai/)
- [Self-Host Your Own Automation Platform with n8n + Docker](/posts/n8n-self-hosted/)
- [TrueNAS Docker Pro video](https://technotim.com/posts/truenas-docker-pro/)

---

🤝 Support the channel and [help keep this site ad-free](/sponsor)

🛍️ Check out all merch: <https://shop.technotim.com/>
