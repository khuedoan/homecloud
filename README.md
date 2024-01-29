# HomeCloud

## Installation

### Hypervisor

```sh
cd ./global/images/metal
```

Build the ISO image:

```sh
make build
```

Burn it into a USB drive:

```sh
make usb drive=/dev/sdX
```

Serve the answer file:

```sh
make serve
```

### Post-installation

Change root password:

```sh
ssh root@${SERVER_IP}
# Default password: root
passwd
```
