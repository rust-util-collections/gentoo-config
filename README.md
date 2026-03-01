# gentoo-config

Configuration files and one-click installation scripts for Gentoo Linux on AMD EPYC workstations.

## One-click installation

Two scripts are provided for different EPYC generations:

| Script | Platform | Arch | Boot method |
|--------|----------|------|-------------|
| `install_gentoo_9004.sh` | EPYC 9004 (Genoa) / Supermicro H13SSL | znver4 | efibootmgr (no initramfs) |
| `install_gentoo_7003.sh` | EPYC 7003 (Milan) / Supermicro H12SSL | znver3 | GRUB + dracut (initramfs required) |

Boot from a Fedora/Ubuntu live USB, set up network, then:

```shell
sudo -i
apt install -y git || dnf install -y git
git clone https://gitee.com/kt10/gentoo-config.git && cd gentoo-config

export TARGET_DISK="/dev/sda"
export ROOT_PASSWORD="your_root_password"
export HOSTNAME="epyc"

# EPYC 9004 series (Genoa) / H13SSL:
bash install_gentoo_9004.sh

# EPYC 7003 series (Milan) / H12SSL:
bash install_gentoo_7003.sh
```

### Optional environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GENTOO_MIRROR` | `https://mirrors.163.com/gentoo` | Portage mirror |
| `TIMEZONE` | `Asia/Shanghai` | System timezone |
| `SSH_PORT` | `22` | SSH listen port |
| `KERNEL_CONFIG_URL` | *(empty)* | URL to download kernel `.config`; empty = use bundled config |
| `EFI_SIZE` | `512M` | EFI partition size |
| `USER_NAME` | `fh` | Non-root user to create |
| `USER_PASSWORD` | *(same as ROOT_PASSWORD)* | Password for non-root user |
| `JOBS` | *(auto-detect via nproc)* | Parallel build jobs |

## Directory structure

```
portage/          Portage make.conf files (main, GNU toolchain, musl)
kernel/           Kernel configs for EPYC 9474F / 7773X on Supermicro boards
shell/            zshrc for regular user and root
nvim/             Neovim config (init.vim)
fonts/            Monaco.ttf
input/            Input method tables (wubi98)
docs/             Notes on crossdev, Docker, networking, etc.
archive/          Old / unused config files
```

## Development environment (LSP)

```shell
rustup component add rust-analyzer

go install golang.org/x/tools/gopls@latest

npm install -g pyright
```

## Reference docs

- [Crossdev / musl cross-compilation](docs/crossdev.md)
- [Docker kernel modules](docs/docker.md)
- [Tips (passwords, etc.)](docs/tips.md)
