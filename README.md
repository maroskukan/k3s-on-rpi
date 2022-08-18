# Running K3s on Raspberry Pi

- [Running K3s on Raspberry Pi](#running-k3s-on-raspberry-pi)
  - [Introduction](#introduction)
  - [Documentation](#documentation)
  - [Benchmarks](#benchmarks)
    - [Storage](#storage)


## Introduction

The purpose of this repository is to document the deployment of K3s cluster on Raspberry Pi. K3s is lightweigh and certified Kubernetes distribution targeted for Edge, IoT, CI and ARM environments. Raspberry PI is power efficient single board computer based on ARM architecture.

The use case I am interested in this project is to have an always on and power efficient kubernetes cluster for running various containerized applications as well as gain practical experience from deploying and managing such infrastructure over the time.


## Documentation

- [k3s](https://k3s.io/)
- [Raspberry PI](https://www.raspberrypi.org/)
- [Pi Storage Benchmark](https://github.com/TheRemote/PiBenchmarks)

## Benchmarks

The following section contains various benchmarks that were evaluated againts components used in this build.

### Storage

The following MicroSD cards were tested and measured using [Pi Storage Benchmark](https://github.com/TheRemote/PiBenchmarks).

Samsung Evo Plus 64 GB scored **1430**.

| Category | Test             | Result                 |
| -------- | ---------------- | ---------------------- |
| HDParm   | Disk Read        | 34.97 MB/s             |
| HDParm   | Cached Disk Read | 37.32 Mb/s             |
| DD       | Disk Write       | 25.3 MB/s              |
| FIO      | 4k random read   | 3434 IOPS (13738 KB/s) |
| FIO      | 4k random write  | 1147 IOPS (4589 KB/s)  |
| IOZone   | 4k read          | 11081 KB/s             |
| IOZone   | 4k write         | 3767 KB/s              |
| IOZone   | 4k random read   | 10954 KB/s             |
| IOZone   | 4k random write  | 3330 KB/s              |


Kingston Canvas Select Plus 64 GB scored **1202**.


| Category | Test             | Result                 |
| -------- | ---------------- | ---------------------- |
| HDParm   | Disk Read        | 43.35 MB/s             |
| HDParm   | Cached Disk Read | 43.10 Mb/s             |
| DD       | Disk Write       | 27.1 MB/s              |
| FIO      | 4k random read   | 2753 IOPS (13738 KB/s) |
| FIO      | 4k random write  | 879 IOPS (4589 KB/s)   |
| IOZone   | 4k read          | 9017 KB/s              |
| IOZone   | 4k write         | 3120 KB/s              |
| IOZone   | 4k random read   | 7395 KB/s              |
| IOZone   | 4k random write  | 3099 KB/s              |
