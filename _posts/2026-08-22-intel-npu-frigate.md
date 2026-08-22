---
layout: post
title: "What Is an NPU Actually For? CPU vs GPU vs NPU in Frigate"
date: 2026-08-22 08:00:00 -0500
categories: hardware
tags: intel npu cpu gpu frigate openvino minisforum ms-03 panther-lake edge-ai computer-vision local-ai homelab
image:
  path: /assets/img/headers/intel-npu-frigate.webp
  lqip: data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAUACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/AOu/4Zo+Md74qsfCvhj9qTWfDvw48R3HiKWz8M33wk8AeIdd0C0nt9Ot7rT7Hxix0u5nt5oElRGudKaWNrmaZ3mmbfX4jhPE/FqlVjiMpw1WpBpKdLEVKMLz0u6cqVeVu8fa2fkfv2YeFeDhVozw2b4qlTmpNwqYenVl+7ipW541aMfeva7pu275j6Vtf+CZnwFNtbHUvFHxVv8AUTBCb++i1nwbZR3l6Y1+1XUdmngSZbRLifzJktlllWBXEQkcIGL/AOIgZq9VhMAk9UnGu2k9k37dXa72V+yMP9QcrWjxePbWjanRim1u0vZOyb1td22uf//Z
---

NPUs are showing up in more computers, but their job is still harder to explain than the CPU or GPU.

I know what I use a CPU for. I know what I use a GPU for. The NPU was kind of a mystery to me.

To find out where it actually fits, I ran the same real-time object detection workload on the CPU, GPU, and NPU inside the [MINISFORUM MS-03](https://store.minisforum.com/products/minisforum-ms-03-workstation). The test used [Frigate](https://github.com/blakeblackshear/frigate), [OpenVINO](https://github.com/openvinotoolkit/openvino), four repeatable camera streams, and the same [YOLOv9](https://github.com/WongKinYiu/yolov9) model for every run.

The NPU did not beat or replace the GPU. It matched the integrated GPU in Frigate as the integrated GPU used less total system power, and left most of the GPU available for video decoding or another workload.

{% include embed/youtube.html id='8NFV6duMKQA' %}
[Watch the video](https://www.youtube.com/watch?v=8NFV6duMKQA)

---

![MINISFORUM MS-03 used for CPU, GPU, and NPU testing](/assets/img/posts/intel-npu-frigate/ms-03-0001.webp){: lqip="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAklEQVR4AewaftIAAADKSURBVAXBsUrDUBSA4f+ec24uSUmsWaoIZhDaoXbSTdx9ACf3dvOxHPRtHJx1cCiCVCM0kJvc+n3ucbM+HFUlWchQURyQUiLGyL7r+G1bdrsfrI+ROAyIKqNLpJQwVUQNVUPVEFXspMoIfuTp5Zk4DCBKUU4pihwT4eb6kmleY3fLGULi7P6Wt48tr+9bJsc1y4tzFs2Mq9UC7xX7a1vMwbw5ZTVveDBDTBH1iA8QO/o+YZ9f3ygwCZ66zKnyDB88UTwje8RnHJzwD7n6PIR8WJ6VAAAAAElFTkSuQmCC" }
_The MINISFORUM MS-03 used for the Frigate CPU, GPU, and NPU comparison._

## Why Frigate made a useful NPU test

A synthetic benchmark can tell me which device is faster, but not which one I would choose for a workload that runs all day.

[Frigate](https://github.com/blakeblackshear/frigate) gave me a better test because object detection is continuous. Video frames keep arriving, inference repeats throughout the day, latency matters, and power adds up over time.

Frigate also supports Intel hardware through [OpenVINO](https://github.com/openvinotoolkit/openvino). That allowed me to keep the application, model, camera feeds, and video decoding path the same while changing only the device used for object detection.

| Processor | Role in the test |
| --- | --- |
| CPU | Runs Frigate and the rest of the application |
| Integrated GPU | Decodes the four video streams |
| OpenVINO detector | Runs on the CPU, GPU, or NPU |

That kept the comparison clean. Frigate, the model, the camera feeds, and video decoding stayed the same. Only the detector device changed between runs. It was one application with one variable changed between runs.

![Four repeatable camera streams running in Frigate](/assets/img/posts/intel-npu-frigate/frigate-four-cameras.webp){: lqip="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAklEQVR4AewaftIAAADnSURBVAXBTy/DYADA4V9f1VYkbS1Tmbkg7YIsEiIi4epL+C4+iosbcRCJg8+AjGQkDjJb0k0nG+v0r/b1PIp2ei7XBq8s2BUUBaSE0dcAJQvZWHbYGrY4dFdRtSjGeblld7/JZmOPUdCmn/hITbBYjfFzjeHkB1GkIU13nQPPxZZjatYSWRIRJVPC7wRz3kCWJUIpSvxJl7PrSx4/Ai7ubnhq9TErR6x4Jwi9TlFIhMxzOr2AVEL77R7Pq2LaM5S/HbrPV/TeHyj+UlTHUDlubKPpJVGcwadkp1bHmI5RxSyGYmHN6fwDqQFhD49De3sAAAAASUVORK5CYII=" }
_Four prerecorded scenes on loop and published as RTSP camera streams for Frigate._

---

## The hardware

The MS-03 uses an Intel Core Ultra 9 386H from the Panther Lake generation. The processor combines a CPU, an integrated Intel GPU, and an NPU rated at up to 50 TOPS.

TOPS (Trillion Operations per Second) measures theoretical AI compute. It is useful for comparing hardware on paper, but it does not tell me how fast Frigate will run, how much of the system it will occupy, or what the machine will pull from the wall.

The rest of the MS-03 also makes sense for a small camera or edge AI server. It has 10 and 2.5 Gigabit Ethernet, dual 10 Gigabit SFP+, multiple NVMe slots, and PCIe expansion.

What mattered here was having all three processors in the same machine. I could compare them without adding a discrete GPU or moving the workload to another system.

![Intel Core Ultra 9 386H specifications used in the MS-03](/assets/img/posts/intel-npu-frigate/ms-03-three-processors.webp){: lqip="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAklEQVR4AewaftIAAACTSURBVG3BsVEDMRCG0W9XGp0CjmEIHNCAh6Erd0Ez1EEdZMTUIHPWSfszDpx4eM+eXk8qa8KAPib7Puljci8f314Q4uv7hwghwZS4lz8/3nEz2u9Gv3RqXbgaIUJihlhyItda6CM4PD/SWuNhXTHgvHU8JZacMIPsZpTsmBmYEREkd2rJuDs3HhJ9BJKYYxBz8p8/CNtDkLG83JYAAAAASUVORK5CYII=" }
_Intel’s specifications for the Core Ultra 9 386H that provides the CPU, integrated GPU, and NPU._

---

## The Panther Lake software gap

Frigate 0.17.2 already supports Intel NPU detection. The problem was not Frigate's OpenVINO detector.

The problem was the Intel userspace stack bundled inside the container (lower in the stack). Ubuntu and OpenVINO on the host could see the NPU, but OpenVINO inside the stock Frigate container could not use this Panther Lake generation.

I built a compatibility image with a newer OpenVINO, Intel NPU userspace, GPU compute runtime, and media stack. The full build is available in my [frigate-intel-npu repository](https://github.com/timothystewart6/frigate-intel-npu).

This remains a Frigate 0.17.2 rebuild. This build does not add a new detector or change Frigate's OpenVINO implementation.

The image can be built from the repository with the following commands.

```bash
git clone https://github.com/timothystewart6/frigate-intel-npu.git
cd frigate-intel-npu
./build.sh
```

The container needs access to both the Intel graphics devices and the NPU device.

```yaml
group_add:
  - "44"
  - "993"

devices:
  - /dev/dri/card0:/dev/dri/card0
  - /dev/dri/renderD128:/dev/dri/renderD128
  - /dev/accel:/dev/accel
```

The group IDs shown here matched the system I tested. Check the `video` and `render` group IDs on your own host before copying them.

The device selection itself is only one line. The same block can target `CPU`, `GPU`, or `NPU`.

```yaml
detectors:
  openvino:
    type: openvino
    device: NPU
    model_path: /openvino-model/yolov9t.xml

model:
  model_type: yolo-generic
  width: 640
  height: 640
```

The NPU path requires a model with static input shapes. The model used here was YOLOv9-tiny exported as a 640 by 640 OpenVINO IR.

A mounted device node does not prove the model is executing on that device. The image includes verification helpers for both accelerators.

```bash
docker exec frigate verify-frigate-npu
docker exec frigate verify-frigate-gpu
```

The NPU check compiles the mounted model and confirms that OpenVINO reports the NPU as the execution device. I also watched the [Intel NPU driver's](https://github.com/intel/linux-npu-driver) busy counter and confirmed it was increasing while the model was running.

![Compatibility Frigate image exposes the NPU while stock Frigate does not](/assets/img/posts/intel-npu-frigate/openvino-device-verification.webp){: lqip="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAklEQVR4AewaftIAAADGSURBVDXBsS4EURSA4f+cGbPDkt3EkmjEioKG6CRKb6DwOp7B9iovoNlWrfMKSgmJ3cwk1+7ccw5T+D6p7p9i8+2FlBLj0QhBcHeGGrD44GZjwe31BaV+fzJ4nVMBZoaI4O78VBUpJR6XSy6PDyi71YqiKGjbFjMj54yZYWb8C3dK9UBVqeuapmnIORMR9PbrIXeHp0xjC1V3VITBek3XdYgIIkLvfLzH7GHG2c4R5aRSrqYTNHaxCII/EfROtse8z5/5kpZf9Q5Vr3uwnHsAAAAASUVORK5CYII=" }
_The compatibility image builds from the pinned Frigate 0.17.2 source before replacing the Intel userspace stack._

---

## Building a repeatable camera workload

I recorded four short scenes around Minneapolis with different amounts of movement, people, and traffic. Each clip was looped in real time with [FFmpeg](https://github.com/FFmpeg/FFmpeg), passed into [go2rtc](https://github.com/AlexxIT/go2rtc), and published as its own RTSP stream.

Frigate saw four normal camera URLs, even though the sources were local video files.

Every run used the same setup.

- Four repeatable camera streams
- YOLOv9-tiny at 640 by 640
- The same Frigate image
- The same GPU hardware video decoding
- The same detection and camera configuration
- About five minutes per run
- Five runs for each processor

The only setting that changed was `detectors.openvino.device`.

I collected Frigate detector latency and throughput along with CPU, GPU, NPU, and wall-power measurements. I sent hardware metrics to [Prometheus](https://github.com/prometheus/prometheus) and graphed in [Grafana](https://github.com/grafana/grafana). Total system power came from a smart plug at the wall.

![Measurements collected during each Frigate test run](/assets/img/posts/intel-npu-frigate/test-methodology.webp){: lqip="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAklEQVR4AewaftIAAACmSURBVDXB3U7CQBCA0W+HsUCoXOiNN0bg/R+IB1BiAAltdrfQ/RltDOe49evO5os5Xddj1TCrTAxw/DNA3apl+f5B9p56PrN925Fz5vv0xcumQRuhvwRU71eeu4HWKsdSyP2eidYR+VwjIjTJ0LE8cQktPgRKrpzSghgH0mjISokxklJCo/cMIfLwM9x4OB4OTMwqyh8nM0QcIjPAAAcYZlBqgWL8AqDnWrWXD+8uAAAAAElFTkSuQmCC" }
_Each run tracked latency, detector throughput, utilization, hardware power, wall power, and repeatability._

---

## CPU vs GPU vs NPU in Frigate

The live Frigate workload produced the following averages.

| Device | Frigate latency | Detector FPS | System power |
| --- | ---: | ---: | ---: |
| CPU | 30.4 ms | 33.0 FPS | 51.4 W |
| GPU | 9.7 ms | 53.5 FPS | 24.8 W |
| NPU | 9.7 ms | 53.3 FPS | 18.3 W |

Moving detection from the CPU to the integrated GPU made the largest performance difference. Detector latency fell from 30.4 milliseconds to 9.7 milliseconds, while throughput increased from about 33 to 53.5 detector frames per second.

The GPU was also pretty much pegged during detection, averaging about 99 percent utilization.

In Frigate, the NPU was pretty much the same. It averaged the same 9.7 milliseconds and 53.3 detector frames per second. A difference of 0.2 FPS isn't meaningful here.

The bigger difference was power and how much GPU headroom was left.

The NPU run used about 6.5 watts less at the wall than the GPU run and about 33 watts less than the CPU run. The NPU averaged about 18 percent utilization. With detection on the NPU, GPU utilization dropped to about 30 percent and was mostly handling video decoding.

That was pretty awesome to see. The NPU handled the continuous detector workload without pinning the GPU I still wanted for video decoding or other work.

![Wall-power history across CPU, GPU, and NPU Frigate runs](/assets/img/posts/intel-npu-frigate/power-usage.webp){: lqip="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAklEQVR4AewaftIAAACpSURBVDXBS07DQBBAwdfdM8SJIwgKrIEF9z8RW0AioICtMD9PIy+okofHJ1dVWmvUWumAuAPOP1ND1ZTFHTWjlsL27pY4RErOlJzx3knpF625Mp3P1BbZ7o/Mbx/IIpgFduOIiCAiBIsDw809JX2xGg7P6OaaqO/kdMK70XFCrxPp8omIscrfL1RVXK6wuAN3lpYIm/2Bn+mVEGAcR9ydlaozzydaa6z+AA8yUN9aDqwOAAAAAElFTkSuQmCC" }
_Wall-power history makes the lower NPU draw visible across the CPU, GPU, and NPU test runs._

{% include image-grid.html
  src1="/assets/img/posts/intel-npu-frigate/results-cpu.webp"
  lqip1="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAklEQVR4AewaftIAAACuSURBVDXBW0oDQRBA0dvPicYMKJH8C/rlNtyXixUSJ2IeTo/aXVMlCp7jrjf3llLicDhiZvyLyyusNUwFbULssrG5TfTLS2ZJdN4jc6Np4sKtkFk4fRb8qSjvj09sj5HhLLyMynYKvJXKcLNm14SPKnicg1UP3vMr3z2Ac/xZLDDnMCDErn/W/YBNI2aGlhFaxdTQMkKt6CzEuQlfu1cwJedMEIEQIcB3mVBVtAk/g9xj+eFX1JYAAAAASUVORK5CYII="
  alt1="Frigate CPU detector result showing latency, throughput, utilization, and wall power"
  caption1="CPU result - 30.4 ms latency, 33 detector FPS, and 51.4 W at the wall."

  src2="/assets/img/posts/intel-npu-frigate/results-gpu.webp"
  lqip2="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAklEQVR4AewaftIAAAC1SURBVDXB3U7CMACA0W9rywY1TAgol96YGC/0FX3boTGsGxtbf2y1F55T7B6fk1KKrjOklPgnqhqt1ozLQPQBqWTksCvY6g0prqiFwDqLj4p1UbGvJf08UQ7TD5/6ibYTnI1H6hf0/Rvfk+Pr4URrLVcXKPmjmyNqVZPdvb4jZUW2aQ7stycyIarmg2kkLDMxRm6Xlt6ccW4hDB1uHvHBImMI3IyBFCnLEjtcyJQQ2L4niz7wCwtoVpwGqUi9AAAAAElFTkSuQmCC"
  alt2="Frigate GPU detector result showing latency, throughput, utilization, and wall power"
  caption2="GPU result - 9.7 ms latency, 53.5 detector FPS, and 24.8 W at the wall."

  src3="/assets/img/posts/intel-npu-frigate/results-npu.webp"
  lqip3="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAklEQVR4AewaftIAAADDSURBVDXBTVKDMACA0Q8SIFa0Mjriwm0XnXG61Ct4hd7Gc7q2Y/1hQoGQkpDG6cL3kqpeRZnlaK2JMfJPFIoMgbjwGD0h8yJS30mW5YLTKUcJweQmQsxZCIVzjrY0pG0381E8svuN7FtPFyo22ye+h4n97T07M9L7mZQErqsHVi81Z5frDeoq46y8qXl+XUMCQqrlW2INzo7YzuO7hs/3H8bDROgP2L7DaIsMfmZoGo5tSiEzghnoDagsJ9qRL30kOM8f/jNfAUo51U0AAAAASUVORK5CYII="
  alt3="Frigate NPU detector result showing latency, throughput, utilization, and wall power"
  caption3="NPU result - 9.7 ms latency, 53.3 detector FPS, and 18.3 W at the wall."

  src4="/assets/img/posts/intel-npu-frigate/results-comparison.webp"
  lqip4="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAklEQVR4AewaftIAAADASURBVDXBMU/CQBiA4fd6dz2ExooQMTHRiYHF0d/gL2fHxTg5kVhCcqVSa9u7+wyDz6Pmq7UYm+O9R0T4p90Ei0ZfjbS+xxibWN4qymJKCAaXaUIciZIz1ROGYaAuWrLmHKlmT+yPwqGJtCwo148czj1fizv27Q/fYyBDwfX8nuVDycVs84x1hoviZsXL6wYUGEQ4ve9AOiQJ1W7LUfVIEpqPNz4rAQETx0BXe0QSLs/htyMphTOW4VRT+UQcRv4A3mBaoWrNGqgAAAAASUVORK5CYII="
  alt4="CPU, GPU, and NPU Frigate benchmark comparison"
  caption4="The GPU and NPU were effectively tied in Frigate, but the NPU used less total system power and left the GPU available."
%}

---

## Why the controlled benchmarks looked different

The standalone OpenVINO tests showed a bigger difference between the GPU and NPU.

The first test used OpenVINO's `benchmark_app` with the same YOLOv9-tiny model in latency mode for 30 seconds.

| Device | Latency | Throughput |
| --- | ---: | ---: |
| CPU | 28.6 ms | 34.5 FPS |
| GPU | 4.2 ms | 221 FPS |
| NPU | 2.2 ms | 315 FPS |

I also ran a synchronous test that more closely matched the one-request-at-a-time path used by Frigate.

| Device | Latency | Throughput |
| --- | ---: | ---: |
| CPU | 29.3 ms | 34.2 FPS |
| GPU | 5.5 ms | 179 FPS |
| NPU | 4.8 ms | 200.5 FPS |

Both controlled tests put the NPU ahead of the integrated GPU. The live Frigate result was different because it measured the whole application rather than the accelerator in isolation.

Frigate was decoding four streams, moving frames, tracking objects, and processing detections. The live workload also needed only about 53 detector frames per second, well below what either accelerator handled in the controlled test.

The controlled tests show what the hardware can do. The Frigate test shows what the whole camera stack actually does.

![OpenVINO benchmark_app results for CPU, GPU, and NPU](/assets/img/posts/intel-npu-frigate/openvino-benchmark-app.webp){: lqip="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAklEQVR4AewaftIAAACySURBVDXB0U7CMBiA0a/tWrp1GiLGS+MND+Rz+j6SeIeJGoiwLDAmW9ufDOI5av60FOcck33TICL8m4V7rI2cDicKrSOLhxnDcKYOFTkL3tTE8YxIRhvHdozoY5/Zhhe+fzM/O2HTwOeu46sdsdWS59dH+kHQClChpvQ11htuFKYK3FVzbKmZFCLC38c7TkAZrkQySinWmxXrtx5EKHJKxEPHKJlJ6T0KGI4dbUrQQo6JC/DmVB4v+rY8AAAAAElFTkSuQmCC" }
_OpenVINO benchmark_app showed a clearer NPU lead when the model was measured outside the full Frigate workload._

![Synchronous OpenVINO CPU, GPU, and NPU results](/assets/img/posts/intel-npu-frigate/openvino-synchronous.webp){: lqip="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAGCAYAAAD68A/GAAAAAklEQVR4AewaftIAAACySURBVDXB0U7CMBiA0a/tWrp1GiLGS+MND+Rz+j6SeIeJGoiwLDAmW9ufDOI5av60FOcck33TICL8m4V7rI2cDicKrSOLhxnDcKYOFTkL3tTE8YxIRhvHdozoY5/Zhhe+fzM/O2HTwOeu46sdsdWS59dH+kHQClChpvQ11htuFKYK3FVzbKmZFCLC38c7TkAZrkQySinWmxXrtx5EKHJKxEPHKJlJ6T0KGI4dbUrQQo6JC/DmVB4v+rY8AAAAAElFTkSuQmCC" }
_The synchronous test brought the GPU and NPU closer while still leaving the NPU ahead._

---

## What the NPU is actually good at

The NPU isn't a smaller replacement for the GPU.

It's another place to run AI inference, especially workloads that stay active without tying up the CPU or GPU all day.

Frigate object detection fits this really well. The detector repeats continuously, the model is supported by OpenVINO, and moving it to the NPU frees the integrated GPU to keep handling video decode or another workload.

The same idea applies to normal people and outside a homelab. On supported systems, [Windows Studio Effects](https://learn.microsoft.com/en-us/windows/apps/develop/windows-integration/studio-effects) can use the NPU for camera effects available to apps such as Zoom and Teams. [Windows Speech Recognition](https://learn.microsoft.com/en-us/windows/ai/apis/speech-recognition) can also run continuously on the NPU. [OpenVINO can run supported language models on Intel NPUs](https://docs.openvino.ai/2026/openvino-workflow-generative/inference-with-genai/inference-with-genai-on-npu.html), although I did not test LLM inference for this comparison.

[Apple calls its version the Neural Engine](https://developer.apple.com/documentation/coreml). [AMD calls its NPU architecture XDNA](https://www.amd.com/en/technologies/xdna.html). [Google uses the TPU name](https://cloud.google.com/tpu). The implementations differ, but the general role is similar. They provide dedicated hardware for supported AI work that does not need to occupy the CPU or GPU.

If I need more GPU compute, the MS-03 also has PCIe expansion that can be adapted to OCuLink for an external GPU. The NPU is not there to replace that. It takes the workloads that make sense for it.

![MINISFORUM MS-03 connected to an external GPU](/assets/img/posts/intel-npu-frigate/ms-03-oculink-egpu.webp){: lqip="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAYACgMBEQACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APzP/Zx/4IueKmutY8M+NPi54CufDGq20MWl61Z+CtV1nVbDUEUxzb/DFzqfh6KK1IuZnaaw8b21xeTpbSXMawwvazfiEfHfI03hnkWaPFyqOKXtMJ9XSS0ftva+09+9pR+r2junK1j9mxvg1nGDisTSznL54aNJSalDEwqtu7kvZKlUhpyu0vbXlezjFHZzf8Grct3LLdj9uuBBdSPcBf8Ahl/G0TMZAuB+0IQMbscEjjivXj4oxklJZI7NJq+Yrqr/APQCfJS4LrqTX1+jo3/zDyfXu53+8//Z" }
_The MS-03 can still use external GPU compute through its PCIe expansion when a workload needs more than the integrated GPU._

What mattered was not whether the NPU won a benchmark. It was moving a workload that runs all day off the GPU without giving up real-world detector performance, while also lowering total system power.

That is where the NPU makes sense to me.

---

## Where to Buy

MINISFORUM MS-03

- [MINISFORUM MS-03 - MINISFORUM store](https://store.minisforum.com/products/minisforum-ms-03-workstation) _(non-affiliate link)_
- [MINISFORUM MS-03 - Amazon](https://amzn.to/3UOCCdN) _(affiliate link)_

Other devices with NPUs

- [Intel Core Ultra systems with an NPU](https://amzn.to/4zyzO4r) _(affiliate link)_
- [AMD Ryzen AI laptops](https://amzn.to/4ghirw8) _(affiliate link)_
- [Apple devices with a Neural Engine](https://amzn.to/3S1BG56) _(affiliate link)_
- [Google Pixel devices with a TPU](https://amzn.to/3Sm6IVo) _(affiliate link)_

(Affiliate links. I may receive a small commission at no cost to you.)

---

> **Disclosure**  
> MINISFORUM sent the MS-03 for testing. They did not sponsor this post or video and had no editorial input into either.
{: .prompt-info }

🤝 Support the channel and [help keep this site ad-free](/sponsor)

⚙️ See all the hardware I recommend at <https://l.technotim.com/gear>
