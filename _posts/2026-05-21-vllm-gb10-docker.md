---
layout: post
title: "Running the Latest vLLM on the NVIDIA DGX Spark"
date: 2026-05-21 08:00:00 -0500
categories: homelab ai
tags: vllm docker nvidia gb10 dgx-spark arm64 cuda homelab ai local-ai gx10
image:
  path: /assets/img/headers/vllm-gb10.webp
  lqip: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAFCAYAAAB8ZH1oAAAAAklEQVR4AewaftIAAADBSURBVAXBsU7CQACA4f+ud22P5oy1dKBEF+IqE5I46KLGxMfwDXwrXsDFhZ0B4+JS1MQ4kEhCwEIvWM7vE4TGB+zRUYTb7tHdM+ztA7+TN/7mz4jlO00rQYrQILUgThQEEb53xya94fT8Cp33McaACFB+uwbh2XlHohWF/CAuVlS2wL7UHFjN+qdCXQwHSClJ05Q4aLi/zFiUj4Q4smvF6MnxuVCo46JDO89xdU376JDyq+J1PAUJJ1nI7HtFa+f5B5qUOQQQ2lKnAAAAAElFTkSuQmCC
---

When I built my local AI cluster on a pair of ASUS Ascent GX10s, the hard part was not serving a model. The hard part was getting a working vLLM image with current components. NVIDIA's official image was already over a month behind by the time I needed it, and waiting on their release schedule was not an option.

If you saw [that post](https://technotim.com/posts/local-ai-gx10/), you know the GX10 is an ARM64 machine built around NVIDIA's GB10 Grace-Blackwell SoC. It is not an x86 server, and it is not a standard consumer GPU. The CUDA architecture is `sm_121a`, which is new enough that most pre-built images either do not exist yet or lag behind current vLLM releases.

So I built my own image pipeline. Here is what it does and how to use it.

---

## The problem with the official image

NVIDIA publishes a vLLM image on NGC:
[catalog.ngc.nvidia.com/orgs/nvidia/containers/vllm](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/vllm)

It works, but it tends to lag upstream.

By the time an NVIDIA vLLM NGC image ships, vLLM upstream has usually moved a few releases ahead. If you want the latest features, bug fixes, or model support, you are waiting on NVIDIA's release schedule rather than pulling directly from the source.

There is also no easy way to see everything that went into the image. The tag tells you the vLLM version, but it does not tell you the exact NCCL commit, the PyTorch build, the FlashInfer version, or which CUDA base digest was used. Pulling `:latest` two weeks apart may give you two different images under the same tag.

---

## eugr's spark-vllm-docker

eugr built [spark-vllm-docker](https://github.com/eugr/spark-vllm-docker), a Dockerfile and set of shell scripts that compile vLLM and its dependencies for the GX10.

That project is what made the two-node cluster test in my GX10 [blog post](https://technotim.com/posts/local-ai-gx10/) possible. I used it for the two-node Ray cluster setup, and it worked well.

But it leans heavily on shell scripts, and I wanted something I could run through GitHub Actions without SSHing into the machine to kick off a manual build. I also wanted every single input pinned so the same build could be repeated later.

So I built my own.

---

## What vllm-gb10 is

[timothystewart6/vllm-gb10](https://github.com/timothystewart6/vllm-gb10) is a vLLM Docker image for the NVIDIA DGX Spark (GB10 / `sm_121a`) that tracks upstream releases directly, built with GitHub Actions on a self-hosted runner that runs directly on the Spark.

Every input is pinned:

| Component | How it is pinned |
| --- | --- |
| CUDA base image | SHA256 digest |
| vLLM | git commit SHA |
| PyTorch, TorchVision, TorchAudio, Triton | exact version |
| NCCL | git commit SHA, built from source |
| FlashInfer | git commit SHA |
| Runtime Python deps | lockfile hash via uv |
| Apt packages | version-pinned lockfile |

All pins live in a single file: `versions.env`. All generated lockfiles live in `locks/`. The same `versions.env` always produces the same image, and the repo includes a `verify-reproducible` workflow that builds twice and diffs five authoritative artifacts to prove it.

---

## The current stack

| Component | Version |
| --- | --- |
| CUDA base | `nvidia/cuda:13.2.0-devel-ubuntu24.04` |
| vLLM | `v0.20.1` |
| PyTorch | `2.11.0` (cu130 build) |
| NCCL | `v2.30.4-1` (built from source) |
| FlashInfer | `0.6.8.post1` |
| Python | 3.12 |
| Architecture | `linux/arm64` |
| CUDA arch target | `sm_121a` |

---

## Quick start

The image is published to both GHCR and Docker Hub on every green build of `main`.

```bash
docker pull ghcr.io/timothystewart6/vllm-gb10:latest

docker run --rm -it \
  --gpus all \
  --ipc=host \
  --network host \
  -v ~/.cache/huggingface:/root/.cache/huggingface \
  ghcr.io/timothystewart6/vllm-gb10:latest \
  vllm serve <model> --host 0.0.0.0 --port 8000 --gpu-memory-utilization 0.7
```

For a pinned version, check the [releases page](https://github.com/timothystewart6/vllm-gb10/releases). Each release lists the exact component table and the immutable tag tied to that build.

---

## Image tags

Each build publishes four tags:

| Tag | Notes |
| --- | --- |
| `v0.20.1-gb10.0` | Canonical, immutable. vLLM version plus stack revision. |
| `v0.20.1-cu13.2-torch2.11-gb10.0` | Same image. Adds CUDA and PyTorch versions for quick scanning. |
| `latest` | Mutable. Always points at the most recent green build of `main`. |
| `sha-<short_sha>` | Immutable, tied to the exact git commit that produced it. |

The `gb10.<N>` counter increments when any non-vLLM input changes on the same vLLM version. It resets to 0 when `VLLM_REF` bumps. There is intentionally no bare `v0.20.1` tag, because that would be mutable.

---

## Bumping versions - the PR flow

I wanted version bumps to be a one-edit change.

1. Edit one or more `_REF` lines in `versions.env` on a branch.
2. Open a pull request. CI picks up the change, runs `scripts/bump.sh` on the Spark runner, and commits the resolved commit SHAs, updated `GB10_BUILD`, and regenerated lockfiles back to your branch.
3. Review the diff and merge.
4. A green build publishes the updated image and creates a GitHub Release.

That is it. The only thing you touch is the ref you want to update.

You can also run `bump.sh` manually on the Spark if you prefer, but that defeats the purpose.

---

## Why build from source

NCCL is compiled from the git SHA rather than pulled from the NVIDIA apt repository. The apt package can embed build timestamps that make it non-reproducible, so the same tag from apt on two different days can produce two different binaries. Pinning to a specific commit SHA gives you something you can actually verify.

There is also a performance reason. GB10 support is still new enough that pre-built NCCL packages can trail the hardware. Building from source with `-gencode=arch=compute_121,code=sm_121` means the CUDA kernels are built for the exact hardware instead of falling back to a compatibility target.

FlashInfer and vLLM get the same treatment. They are compiled from source with the same gencode flag, fully native to the platform.

---

## Reproducibility

The whole point of pinning everything is to prove the build is stable.

The `verify-reproducible` workflow in CI builds the image twice, back to back, extracts five authoritative artifacts from each build, and diffs them:

- `nccl-sha256.txt` - SHA256 of libnccl.so.2 (debug-stripped for comparison)
- `wheel-sha256.txt` - SHA256 of the pure (non-compiled) FlashInfer wheels
- `build-metadata.yaml` - all version pins, repo SHA, and build timestamp
- `pip-freeze.txt` - pip freeze output from the runner image
- `apt-versions.txt` - full installed package list from dpkg

If any of those differ between the two builds, the workflow fails.

Compiled CUDA extension wheels (vLLM, flashinfer-jit-cache) are compared but logged as informational only. On this architecture, nvcc can still embed non-deterministic metadata in host ELF debug sections, which is an upstream compiler issue rather than something fixable in the build system.

---

## Is this for you

If you have a GX10 or a DGX Spark and you just want vLLM running quickly, the NGC image or eugr's project will get you there with less setup.

This repo is for the case where you want to stay on the latest vLLM release without waiting on NVIDIA's schedule, and you also want to know exactly what went into the image and pin a tag that will not change under you. That is the gap it fills.

---

## Two-node Ray cluster example

This is the setup I run on my two GX10s serving [MiniMax-M2.7-AWQ](https://huggingface.co/cyankiwi/MiniMax-M2.7-AWQ-4bit), a ~229B parameter MoE model at AWQ 4-bit. The two nodes are connected over a direct QSFP link for NCCL transport.

The head node starts the Ray cluster and runs `vllm serve`. The worker node joins the cluster and contributes its GPU. Together they give you TP=2 across both machines.

You will need a `.env` file alongside each compose file:

```bash
HEAD_IP=<qsfp ip of gx10-1>
WORKER_IP=<qsfp ip of gx10-2>
HF_TOKEN=<huggingface token>
QSFP_IFACE=enp1s0f0np0
```

**Head node** (`docker-compose.yml` on gx10-1):

```yaml
services:
  vllm-ray-head:
    image: ghcr.io/timothystewart6/vllm-gb10:latest
    container_name: vllm-ray-head
    restart: unless-stopped
    network_mode: host
    ipc: host
    shm_size: '10.24gb'
    # privileged is required to reach ~40 tok/sec on GB10. Without it,
    # generation drops to ~24 tok/sec. Tested 2026-04-29.
    privileged: true
    ulimits:
      memlock: -1
    volumes:
      - /mnt/llm/models/huggingface:/root/.cache/huggingface
    env_file:
      - .env
    environment:
      - HF_TOKEN=${HF_TOKEN}
      - HUGGING_FACE_HUB_TOKEN=${HF_TOKEN}
      - VLLM_HOST_IP=${HEAD_IP}
      - UCX_NET_DEVICES=${QSFP_IFACE}
      - NCCL_SOCKET_IFNAME=${QSFP_IFACE}
      - OMPI_MCA_btl_tcp_if_include=${QSFP_IFACE}
      - GLOO_SOCKET_IFNAME=${QSFP_IFACE}
      - TP_SOCKET_IFNAME=${QSFP_IFACE}
      - RAY_memory_monitor_refresh_ms=0
      - RAY_num_prestart_python_workers=0
      - RAY_object_store_memory=1073741824
      - MASTER_ADDR=${HEAD_IP}
      - MN_IF_NAME=${QSFP_IFACE}
      - SAFETENSORS_FAST_GPU=1
      - NCCL_IB_DISABLE=0
      - NCCL_IB_HCA=rocep1s0f0,roceP2p1s0f0
      - NCCL_ALGO=Ring
      - NCCL_MIN_NCHANNELS=4
      - OMP_NUM_THREADS=4
    entrypoint: ["/bin/bash", "-c"]
    # sleep 60 gives the worker time to join before vllm allocates the placement
    # group. Without it, vllm can fall back to single-GPU mode silently.
    command:
      - "ray start --head --node-ip-address=${HEAD_IP} --port=6379 --object-store-memory 1073741824 --num-cpus 2 --include-dashboard=false --disable-usage-stats && sleep 60 && vllm serve cyankiwi/MiniMax-M2.7-AWQ-4bit --host 0.0.0.0 --port 8000 --trust-remote-code --tensor-parallel-size 2 --distributed-executor-backend ray --gpu-memory-utilization 0.8 --load-format fastsafetensors --max-model-len 196608 --enable-auto-tool-choice --tool-call-parser minimax_m2 --reasoning-parser minimax_m2"
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    healthcheck:
      test: ["CMD", "curl", "-sf", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 60
      start_period: 1800s
```

**Worker node** (`docker-compose.yml` on gx10-2):

```yaml
services:
  vllm-ray-worker:
    image: ghcr.io/timothystewart6/vllm-gb10:latest
    container_name: vllm-ray-worker
    restart: unless-stopped
    network_mode: host
    ipc: host
    shm_size: '10.24gb'
    privileged: true
    ulimits:
      memlock: -1
    volumes:
      - /mnt/llm/models/huggingface:/root/.cache/huggingface
    env_file:
      - .env
    environment:
      - HF_TOKEN=${HF_TOKEN}
      - HUGGING_FACE_HUB_TOKEN=${HF_TOKEN}
      - VLLM_HOST_IP=${WORKER_IP}
      - UCX_NET_DEVICES=${QSFP_IFACE}
      - NCCL_SOCKET_IFNAME=${QSFP_IFACE}
      - OMPI_MCA_btl_tcp_if_include=${QSFP_IFACE}
      - GLOO_SOCKET_IFNAME=${QSFP_IFACE}
      - TP_SOCKET_IFNAME=${QSFP_IFACE}
      - RAY_memory_monitor_refresh_ms=0
      - RAY_num_prestart_python_workers=0
      - RAY_object_store_memory=1073741824
      - MASTER_ADDR=${HEAD_IP}
      - MN_IF_NAME=${QSFP_IFACE}
      - SAFETENSORS_FAST_GPU=1
      - NCCL_IB_DISABLE=0
      - NCCL_IB_HCA=rocep1s0f0,roceP2p1s0f0
      - NCCL_ALGO=Ring
      - NCCL_MIN_NCHANNELS=4
      - OMP_NUM_THREADS=4
    entrypoint: ["/bin/bash", "-c"]
    command:
      - "ray start --address=${HEAD_IP}:6379 --node-ip-address=${WORKER_IP} --object-store-memory 1073741824 --num-cpus 2 --disable-usage-stats --block"
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    healthcheck:
      test: ["CMD", "ray", "status"]
      interval: 10s
      timeout: 10s
      retries: 30
      start_period: 60s
```

The flag choices for this model are documented in eugr's [MiniMax-M2.7-AWQ recipe](https://github.com/eugr/spark-vllm-docker/blob/main/recipes/minimax-m2.7-awq.yaml). If you are serving a different model, adjust `--gpu-memory-utilization`, `--max-model-len`, `--tool-call-parser`, and `--reasoning-parser` to match your model's recipe.

---

## Links

- Repository: [github.com/timothystewart6/vllm-gb10](https://github.com/timothystewart6/vllm-gb10)
- Image (GHCR): [ghcr.io/timothystewart6/vllm-gb10](https://github.com/timothystewart6/vllm-gb10/pkgs/container/vllm-gb10)
- Image (Docker Hub): [hub.docker.com/r/timothystewart6/vllm-gb10](https://hub.docker.com/r/timothystewart6/vllm-gb10)
- eugr's spark-vllm-docker (the original community project): [github.com/eugr/spark-vllm-docker](https://github.com/eugr/spark-vllm-docker)
- NVIDIA NGC vLLM image: [catalog.ngc.nvidia.com/orgs/nvidia/containers/vllm](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/vllm)
- My GX10 cluster writeup: [technotim.com/posts/local-ai-gx10](https://technotim.com/posts/local-ai-gx10/)

---

🤝 Support the channel and [help keep this site ad-free](/sponsor)

⚙️ See all the hardware I recommend at <https://l.technotim.com/gear>
