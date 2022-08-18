# Running K3s on Raspberry Pi

- [Running K3s on Raspberry Pi](#running-k3s-on-raspberry-pi)
	- [Introduction](#introduction)
	- [Documentation](#documentation)
	- [Dependencies](#dependencies)
		- [DHCP](#dhcp)
	- [Installation](#installation)
		- [Prepare SD Card](#prepare-sd-card)
	- [First Boot](#first-boot)
	- [Benchmarks](#benchmarks)
		- [Storage](#storage)


## Introduction

The purpose of this repository is to document the deployment of K3s cluster on Raspberry Pi. K3s is lightweigh and certified Kubernetes distribution targeted for Edge, IoT, CI and ARM environments. Raspberry PI is power efficient single board computer based on ARM architecture.

The use case I am interested in this project is to have an always on and power efficient kubernetes cluster for running various containerized applications as well as gain practical experience from deploying and managing such infrastructure over the time.


## Documentation

- [k3s](https://k3s.io/)
- [Raspberry PI](https://www.raspberrypi.org/)
- [Pi Storage Benchmark](https://github.com/TheRemote/PiBenchmarks)


## Dependencies

### DHCP

When Raspberry PI OS boots it will use DHCP to acquire IP address from DHCP server. In order to have predictable host to IP mappings, we need to create static host entries on the DHCP server.

The exact configuration varies between different network devices.

In case of OpenWrt, I had to append the following lines to `/etc/config/dhcp` configuration file.

```bash
config host
	option name 'kube1'
	option dns '1'
	option ip '10.0.2.201'

config host
	option name 'kube2'
	option dns '1'
	option ip '10.0.2.202'

config host
	option name 'kube3'
	option dns '1'
	option ip '10.0.2.203'
```

Once all nodes boot, you can test reachability using `ping` utility:

```bash
for i in {1..3}
do
  ping -c 3 kube$i | grep bytes
done
```


## Installation

### Prepare SD Card

The automated option includes installation of Raspberry PI Imager tool. With this tool you are able to define the following configuration settings before flashing the SD Card.

| Key                                  | Value                         |
| ------------------------------------ | ----------------------------- |
| Operating System                     | Raspberry Pi OS Lite (64-bit) |
| Hostname                             | kube1, kube2, kube3           |
| Enable SSH                           | True                          |
| Allow public-key authentication only | True                          |
| Set authorized_keys for 'ansible'    | <your-public-key>             |
| Username                             | ansible                       |
| Password                             | <your-password>               |
| Configure wireless LAN               | True                          |
| Wireles LAN country                  | SK                            |
| SSID                                 | <your-ssid>                   |
| Set locale settings                  | True                          |
| Time zone                            | Europe/Bratislava             |
| Keyboard layout                      | us                            |


## First Boot

Once the flashing process is finished insert SD card and power on. The Pies should be available on your local network for further configuration vai Ansible.


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
