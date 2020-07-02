# Crossdev (musl cross-compilation)

Reference: https://wiki.gentoo.org/wiki/Crossdev

musl cross-toolchain make.conf: [portage/make.conf.musl](../portage/make.conf.musl)

## Setup

```shell
emerge -avq crossdev

PORTAGE_CONFIGROOT=/usr/x86_64-unknown-linux-musl eselect profile list
PORTAGE_CONFIGROOT=/usr/x86_64-unknown-linux-musl eselect profile set XXX

mkdir -p /var/db/repos/crossdev/{profiles,metadata}
echo 'crossdev' > /var/db/repos/crossdev/profiles/repo_name
echo 'masters = gentoo' > /var/db/repos/crossdev/metadata/layout.conf
chown -R portage:portage /var/db/repos/crossdev
mkdir -p /etc/portage/repos.conf

echo "[crossdev]
location = /var/db/repos/crossdev
priority = 10
masters = gentoo
auto-sync = no" > /etc/portage/repos.conf/crossdev.conf

crossdev --stable -t x86_64-unknown-linux-musl
CHOST=x86_64-unknown-linux-musl cross-emerge -avq openssl net-misc/curl
```

## MUSL: "rustc: Dynamic loading not supported"

Disable the default `static link` feature:

```shell
# ~/.bashrc or ~/.zshrc
export RUSTFLAGS="-C target-feature=-crt-static"
```
