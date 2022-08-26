# Running K3s on Raspberry Pi

- [Running K3s on Raspberry Pi](#running-k3s-on-raspberry-pi)
	- [Introduction](#introduction)
	- [Documentation](#documentation)
	- [Materials](#materials)
	- [Dependencies](#dependencies)
		- [Network Management](#network-management)
			- [DHCP](#dhcp)
		- [Configuration Management](#configuration-management)
	- [Installation](#installation)
		- [Prepare SD Card](#prepare-sd-card)
		- [First Boot](#first-boot)
		- [Configuration](#configuration)
		- [Verification](#verification)
	- [Customization](#customization)
		- [MetallLB](#metalllb)
			- [Installation](#installation-1)
			- [Troubleshooting](#troubleshooting)
	- [Benchmarks](#benchmarks)
		- [Storage](#storage)


## Introduction

The purpose of this repository is to document the deployment of K3s cluster on Raspberry Pi. K3s is lightweigh and certified Kubernetes distribution targeted for Edge, IoT, CI and ARM environments. Raspberry PI is power efficient single board computer based on ARM architecture.

The use case I am interested in this project is to have an always on and power efficient kubernetes cluster for running various containerized applications as well as gain practical experience from deploying and managing such infrastructure over the time.


## Documentation

- [k3s](https://k3s.io/)
- [Raspberry PI](https://www.raspberrypi.org/)
- [Pi Storage Benchmark](https://github.com/TheRemote/PiBenchmarks)


## Materials

The following materials were used in this build:

| Part Name                         | Part Description   | Part Quantity |
| --------------------------------- | ------------------ | ------------- |
| Raspberry Pi 4 Model B 4GB        | ARM SoC Rev 1.5    | 4             |
| Raspberry Pi 4 USB-C PSU          | PSU 5.1V / 3.0A DC | 4             |
| SanDisk Ultra UHS-I A1 Class 10   | MicroSD Card       | 4             |
| Acrylic Stackable Case            | Modular Case       | 1             |


## Dependencies

### Network Management

#### DHCP

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

config host
	option name 'kube4'
	option dns '1'
	option ip '10.0.2.204'
```

Once all nodes boot, you can test reachability using `ping` utility:

```bash
for i in {1..4}
do
  ping -c 3 kube$i.home | grep bytes
done
```


### Configuration Management

In order to leverage Ansible for configuration management you need to ensure that the following prerequsities are met:

- Python runtime - [virtual environment recommended](https://github.com/pyenv/pyenv), tested with version 3.10.2
- Python modules - described in `requirements.txt` this will also install `ansible-core`
- Ansible Galaxy collections - described in `requirements.yml`

```bash
pip install --upgrade pip setuptools
pip install -r requirements.txt
```

```bash
ansible-galaxy install -r requirements.yml
```

Once the nodes are up and running, add their SSH fingerprints to `~./ssh/known_host`:

```bash
for i in {1..4}
do
  ssh-keygen -f ~/.ssh/known_hosts -R "kube$i.home"
  ssh-keygen -f ~/.ssh/known_hosts -R "10.0.2.20$i"
  ssh-keyscan -H kube$i.home >> ~/.ssh/known_hosts
done
```

Finally, verify that ansible can reach all nodes using `ping` module:

```bash
ansible -m ping cluster
```


## Installation

### Prepare SD Card

The automated option includes installation of Raspberry PI Imager tool. With this tool you are able to define the following configuration settings before flashing the SD Card.

| Key                                  | Value                         |
| ------------------------------------ | ----------------------------- |
| Operating System                     | Raspberry Pi OS Lite (64-bit) |
| Hostname                             | kube1, kube2, kube3, kube4    |
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


### First Boot

Once the flashing process is finished insert SD card and power on. The Pies should be available on your local network for further configuration vai Ansible.


### Configuration

Once we met all prerequisites described in [Configuration Management](#configuration-management) and reviewed or updated the `default.config.yml` file we are ready to execute the main playbook.

> **Warning**: If you set update_packages to true depending on update requiremnets, nodes may be rebooted before continuing with rest the the tasks.

```bash
ansible-playbook main.yml
```


### Verification

Once the configuration has been applied, it is time to verify the cluster state. Start by downloading the kube config file from master node:

```bash
scp -i ~/.ssh/home/ansible-ed25519 \
    ansible@kube1.home:~/.kube/config ~/.kube/k3s-config.yaml
```

Next, update your `KUBECONFIG` variable to point to downloaded file:

```bash
export KUBECONFIG=~/.kube/k3s-config.yaml
```

Finally, verify the node state:

```bash
kubectl get nodes -o wide
```

If everything worked correctly you should see your nodes in `Ready` state:

```bash
NAME         STATUS   ROLES                  AGE     VERSION        INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION   CONTAINER-RUNTIME
kube1.home   Ready    control-plane,master   12m     v1.24.3+k3s1   10.0.2.201    <none>        Debian GNU/Linux 11 (bullseye)   5.15.56-v8+      containerd://1.6.6-k3s1
kube3.home   Ready    <none>                 9m52s   v1.24.3+k3s1   10.0.2.203    <none>        Debian GNU/Linux 11 (bullseye)   5.15.56-v8+      containerd://1.6.6-k3s1
kube2.home   Ready    <none>                 9m52s   v1.24.3+k3s1   10.0.2.202    <none>        Debian GNU/Linux 11 (bullseye)   5.15.56-v8+      containerd://1.6.6-k3s1
kube4.home   Ready    <none>                 9m51s   v1.24.3+k3s1   10.0.2.204    <none>        Debian GNU/Linux 11 (bullseye)   5.15.56-v8+      containerd://1.6.6-k3s1
```


### Customization

Apply `worker` labels to node 2 through 4:

```bash
for i in {2..4}
do
  kubectl label nodes kube$i.home kubernetes.io/role=worker
  kubectl label nodes kube$i.home node-type=worker
done
```

Verify afterwards with `kubectl get nodes`.

```bash
NAME         STATUS   ROLES                  AGE   VERSION
kube1.home   Ready    control-plane,master   15h   v1.24.3+k3s1
kube3.home   Ready    worker                 15h   v1.24.3+k3s1
kube4.home   Ready    worker                 15h   v1.24.3+k3s1
kube2.home   Ready    worker                 15h   v1.24.3+k3s1
```


## Customization

### MetallLB

#### Installation

```bash
kubectl apply -f manifests/MetalLB/metallb-native.yaml
```

Update the `addresses` value to correspond to your IP network range you want to allocate to LoadBalancer service.

```bash
kubectl apply -f manifest/MetalLB/AddressPool.yaml
```

#### Troubleshooting

In case the cluster nodes are using wireless interface, you may need to apply this [workaround](https://github.com/metallb/metallb/issues/454). Otherwise the allocated address for LoadBalancer service may not be reachable automatically.



## Benchmarks

The following section contains various benchmarks that were evaluated againts components used in this build.

### Storage

The following MicroSD cards were tested and measured using [Pi Storage Benchmark](https://github.com/TheRemote/PiBenchmarks).

```bash
sudo curl https://raw.githubusercontent.com/TheRemote/PiBenchmarks/master/Storage.sh | sudo bash
```

SanDisk Ultra UHS-I A1 Class 10 U1 64 GB scored **1225**.

| Category | Test             | Result                 |
| -------- | ---------------- | ---------------------- |
| HDParm   | Disk Read        | 42.98 MB/s             |
| HDParm   | Cached Disk Read | 40.58 Mb/s             |
| DD       | Disk Write       | 19.7 MB/s              |
| FIO      | 4k random read   | 3116 IOPS (12465 KB/s) |
| FIO      | 4k random write  | 859 IOPS (3437 KB/s)   |
| IOZone   | 4k read          | 9790 KB/s              |
| IOZone   | 4k write         | 4024 KB/s              |
| IOZone   | 4k random read   | 9729 KB/s              |
| IOZone   | 4k random write  | 2863 KB/s              |

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
