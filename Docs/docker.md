# Docker kernel modules on Gentoo

Load required modules at boot via `/etc/local.d/modprobe.start`
(auto-generated as `gentoo-local-modprobe.service`):

```shell
modprobe tun
modprobe veth

modprobe br_netfilter
modprobe iptable_filter

modprobe nf_nat
modprobe iptable_nat
modprobe xt_nat

modprobe nf_conntrack
modprobe xt_conntrack

modprobe xt_MASQUERADE
modprobe xt_addrtype
```

Make Docker depend on module loading:

```
# /lib/systemd/system/docker.service
[Unit]
...
Requires=docker.socket gentoo-local-modprobe.service
...
```
