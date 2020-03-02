## FreeRADIUS Plugin with CaptivePortal Integration for OPNsense Firewall

* Netword Access Server (NAS)
* Web UI
* User Authentication, Authorization and Accounting (AAA)
* Login Time
* Session Time
* Bandwidth Limit
* Traffic Limit
* Users and Usergroups
* Customizable CaptivePortal Landing Page 
* Session Status Panel (Download, Upload, Packets, Duration)
* IPFW Traffic Shaper Integration

## Prerequisites

Based on the instructions provided by https://github.com/opnsense/tools

```bash
root@opnsense# pkg install git
root@opnsense# cd /usr
root@opnsense# git clone https://github.com/opnsense/tools
root@opnsense# cd tools
root@opnsense# make update
root@opnsense# make vga # or dvd or whatever else
```

## Development

FreeRADIUS plugin Development and Test:

```bash
root@opnsense# cd /usr/freeradius-captiveportal
root@opnsense# ./build upgrade_fr
```

CaptivePortal Development and Test:

```bash
root@opnsense# cd /usr/freeradius-captiveportal
root@opnsense# ./build upgrade_cp
```

## Deployments

FreeRADIUS Plugin Build:

```bash
root@opnsense# cd /usr/freeradius-captiveportal
root@opnsense# ./build plugins # will be saved into /usr/build/opnsense/plugins
```

Install FreeRADIUS plugin on target device:
```bash
root@opnsense# cd /usr/freeradius-captiveportal
root@opnsense# ./install fr plugin_path
```

OPNsense Image Build:

DVD image:

```bash
root@opnsense# cd /usr/freeradius-captiveportal
root@opnsense# ./build core
root@opnsense# ./build dvd # will be saved into /usr/build/opnsense/images
```

VGA image:

```bash
root@opnsense# cd /usr/freeradius-captiveportal
root@opnsense# ./build core
root@opnsense# ./build vga # will be saved into /usr/build/opnsense/images
```

## Author
Reza Ebrahimi <<reza.ebrahimi.dev@gmail.com>>