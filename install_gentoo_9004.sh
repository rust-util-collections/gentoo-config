#!/bin/bash
#
# Gentoo Linux interactive installation script
# Platform: AMD EPYC 9004 series (Genoa, znver4) / Supermicro H13SSL
#
# This script uses dracut + GRUB for boot (unified with 7003 script).
# Using initramfs ensures CPU microcode is loaded correctly at boot.
#
# Usage:
#   Boot from a Fedora/Ubuntu live USB, set up network, then run:
#
#     sudo -i
#     apt-get install -y git || dnf install -y git
#     git clone https://gitee.com/kt10/gentoo-config.git && cd gentoo-config
#
#     export TARGET_DISK="/dev/sda"
#     export ROOT_PASSWORD="your_root_password"
#     export HOSTNAME="epyc"
#     bash install_gentoo_9004.sh
#
# Optional environment variables (with defaults):
#     export GENTOO_MIRROR="https://distfiles.gentoo.org"
#     export TIMEZONE="Asia/Shanghai"
#     export SSH_PORT="22"
#     export KERNEL_CONFIG_URL=""   # URL to download kernel .config, empty = use bundled config from this repo
#     export EFI_SIZE="512MiB"
#     export USER_NAME="fh"        # non-root user to create
#     export USER_PASSWORD=""       # password for non-root user, empty = same as ROOT_PASSWORD
#     export JOBS=""                # parallel build jobs, empty = auto-detect (nproc)
#

set -euo pipefail

#######################################
# Required variables - must be set
#######################################
: "${TARGET_DISK:?'ERROR: TARGET_DISK must be set, e.g. export TARGET_DISK=/dev/sda'}"
: "${ROOT_PASSWORD:?'ERROR: ROOT_PASSWORD must be set, e.g. export ROOT_PASSWORD=yourpassword'}"

#######################################
# Optional variables with defaults
#######################################
HOSTNAME="${HOSTNAME:-epyc}"
GENTOO_MIRROR="${GENTOO_MIRROR:-https://distfiles.gentoo.org}"
TIMEZONE="${TIMEZONE:-Asia/Shanghai}"
SSH_PORT="${SSH_PORT:-22}"
EFI_SIZE="${EFI_SIZE:-512MiB}"
USER_NAME="${USER_NAME:-fh}"
USER_PASSWORD="${USER_PASSWORD:-${ROOT_PASSWORD}}"
JOBS="${JOBS:-$(nproc)}"

REPO_URL="https://gitee.com/kt10/gentoo-config.git"

# Derived variables
MOUNT_POINT="/mnt/gentoo"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# If running outside the repo (e.g. user downloaded the script alone), clone it
if [[ ! -d "${SCRIPT_DIR}/.git" ]]; then
    for cmd in git; do
        command -v "${cmd}" >/dev/null || { apt-get install -y "${cmd}" 2>/dev/null || dnf install -y "${cmd}" 2>/dev/null || true; }
    done
    CLONE_DIR="/tmp/gentoo-config"
    rm -rf "${CLONE_DIR}"
    git clone "${REPO_URL}" "${CLONE_DIR}"
    SCRIPT_DIR="${CLONE_DIR}"
fi

KERNEL_CONFIG_FILE="${SCRIPT_DIR}/kernel/EPYC_9474F_supermicro_h13_ssl___without_initramfs_without_netfilter"

# Detect disk type for partition naming (nvme vs sata/sas)
if [[ "${TARGET_DISK}" == *"nvme"* ]]; then
    PART_PREFIX="${TARGET_DISK}p"
else
    PART_PREFIX="${TARGET_DISK}"
fi

#######################################
# Color output helpers
#######################################
info()  { echo -e "\033[1;32m>>> $*\033[0m"; }
warn()  { echo -e "\033[1;33m!!! $*\033[0m"; }
error() { echo -e "\033[1;31mERROR: $*\033[0m" >&2; exit 1; }

#######################################
# Pre-flight checks
#######################################
info "Pre-flight checks..."

[[ "$(id -u)" -eq 0 ]] || error "This script must be run as root"
[[ -b "${TARGET_DISK}" ]] || error "TARGET_DISK=${TARGET_DISK} is not a block device"
[[ -d /sys/firmware/efi ]] || error "System not booted in UEFI mode! Please reboot in UEFI mode."

for cmd in wget parted mkfs.xfs mkfs.vfat; do
    if ! command -v "${cmd}" >/dev/null; then
        pkg=""
        case "${cmd}" in
            mkfs.xfs) pkg="xfsprogs" ;;
            mkfs.vfat) pkg="dosfstools" ;;
            *) pkg="${cmd}" ;;
        esac
        apt-get install -y "${pkg}" 2>/dev/null || dnf install -y "${pkg}" 2>/dev/null || true
    fi
done

info "Target disk: ${TARGET_DISK}"
info "Hostname:    ${HOSTNAME}"
info "Mirror:      ${GENTOO_MIRROR}"
info "Timezone:    ${TIMEZONE}"

# Partition naming (determined early for idempotency checks)
EFI_PART="${PART_PREFIX}1"
ROOT_PART="${PART_PREFIX}2"

#######################################
# Step 1-2: Partition and format (idempotent)
#######################################
disk_needs_setup=true
if [[ -b "${EFI_PART}" ]] && [[ -b "${ROOT_PART}" ]]; then
    efi_fstype=$(blkid -s TYPE -o value "${EFI_PART}" 2>/dev/null || true)
    root_fstype=$(blkid -s TYPE -o value "${ROOT_PART}" 2>/dev/null || true)
    if [[ "${efi_fstype}" == "vfat" ]] && [[ "${root_fstype}" == "xfs" ]]; then
        # Verify EFI partition size matches expected
        efi_actual_bytes=$(blockdev --getsize64 "${EFI_PART}" 2>/dev/null || echo 0)
        _efi_num="${EFI_SIZE%%[A-Za-z]*}"
        case "${EFI_SIZE}" in
            *GiB) _efi_expected=$((_efi_num * 1073741824)) ;;
            *)    _efi_expected=$((_efi_num * 1048576)) ;;
        esac
        _efi_tolerance=$((_efi_expected / 20))  # 5% tolerance for alignment
        if (( efi_actual_bytes < _efi_expected - _efi_tolerance )); then
            warn "EFI partition too small: $(( efi_actual_bytes / 1048576 ))MiB (expected ~$(( _efi_expected / 1048576 ))MiB), will repartition"
        else
            disk_needs_setup=false
            info "Step 1-2: Disk already partitioned and formatted (EFI=vfat $(( efi_actual_bytes / 1048576 ))MiB, root=xfs), skipping"
        fi
    fi
fi

if [[ "${disk_needs_setup}" == "true" ]]; then
    echo ""
    warn "ALL DATA ON ${TARGET_DISK} WILL BE DESTROYED!"
    echo ""
    read -rp "Continue? (yes/no): " confirm
    [[ "${confirm}" == "yes" ]] || { echo "Aborted."; exit 1; }

    info "Step 1: Partitioning ${TARGET_DISK}..."
    parted -s "${TARGET_DISK}" mklabel gpt
    parted -s -a optimal "${TARGET_DISK}" mkpart "EFI" fat32 0% "${EFI_SIZE}"
    parted -s "${TARGET_DISK}" set 1 esp on
    parted -s -a optimal "${TARGET_DISK}" mkpart "root" xfs "${EFI_SIZE}" 100%

    sleep 2
    partprobe "${TARGET_DISK}" 2>/dev/null || true
    sleep 1

    info "Step 2: Formatting partitions..."
    mkfs.vfat -F 32 "${EFI_PART}"
    mkfs.xfs -f "${ROOT_PART}"

    info "Partitions created: EFI=${EFI_PART} ROOT=${ROOT_PART}"
fi

#######################################
# Step 3: Mount and prepare
#######################################
info "Step 3: Mounting filesystems..."

mkdir -p "${MOUNT_POINT}"
if mountpoint -q "${MOUNT_POINT}" 2>/dev/null; then
    info "  ${MOUNT_POINT} already mounted, skipping"
else
    mount -o noatime,discard,allocsize=64k,inode64,logbufs=8,logbsize=256k "${ROOT_PART}" "${MOUNT_POINT}"
fi
mkdir -p "${MOUNT_POINT}/boot/efi"
if mountpoint -q "${MOUNT_POINT}/boot/efi" 2>/dev/null; then
    info "  ${MOUNT_POINT}/boot/efi already mounted, skipping"
else
    mount "${EFI_PART}" "${MOUNT_POINT}/boot/efi"
fi

#######################################
# Step 4: Download and extract stage3
#######################################
if [[ -x "${MOUNT_POINT}/usr/bin/emerge" ]]; then
    info "Step 4: Stage3 already extracted, skipping"
else
    info "Step 4: Downloading stage3 (openrc)..."

    STAGE3_URL="${GENTOO_MIRROR}/releases/amd64/autobuilds"
    # Find latest stage3 openrc tarball
    STAGE3_LIST=$(wget -qO- "${STAGE3_URL}/latest-stage3-amd64-openrc.txt" 2>/dev/null || true)
    STAGE3_PATH=$(echo "${STAGE3_LIST}" | grep -v '^#' | grep -v '^-' | grep -v '^$' | grep 'stage3' | head -1 | awk '{print $1}')

    if [[ -z "${STAGE3_PATH}" ]]; then
        warn "Failed to parse stage3 URL from mirror. Raw response:"
        echo "${STAGE3_LIST:-<empty>}" | head -20
        error "Failed to find stage3 tarball URL from ${STAGE3_URL}/latest-stage3-amd64-openrc.txt"
    fi

    STAGE3_FULL_URL="${STAGE3_URL}/${STAGE3_PATH}"
    STAGE3_FILE=$(basename "${STAGE3_PATH}")

    info "Downloading ${STAGE3_FULL_URL}..."
    cd "${MOUNT_POINT}"
    rm -f "${STAGE3_FILE}"
    wget "${STAGE3_FULL_URL}" -O "${STAGE3_FILE}"

    info "Extracting stage3..."
    tar xpf "${STAGE3_FILE}" --numeric-owner
    rm -f "${STAGE3_FILE}"
fi

#######################################
# Step 5: Configure make.conf
#######################################
info "Step 5: Configuring make.conf..."

cat > "${MOUNT_POINT}/etc/portage/make.conf" << 'MAKECONF'
CFLAGS="-march=znver4 -O2 -pipe"
CXXFLAGS="${CFLAGS}"
CHOST="x86_64-pc-linux-gnu"

USE="-systemd -multilib -elogind -consolekit -X -wayland -iptables -firewalld -tcpd -gpm -cdda -sftp -tftp -ftp -pop3 -smtp -samba -ldap -doc -debug -emacs"

CPU_FLAGS_X86="aes avx avx2 avx512f avx512dq avx512cd avx512bw avx512vl avx512vbmi avx512vbmi2 avx512vnni avx512bitalg avx512vpopcntdq avx512bf16 f16c fma3 mmx mmxext pclmul popcnt rdrand sha sse sse2 sse3 sse4_1 sse4_2 sse4a ssse3 vpclmulqdq"

FEATURES="splitdebug"

ABI_X86="64"
GRUB_PLATFORMS="efi-64"

LLVM_TARGETS="X86 BPF WebAssembly"

ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"
ACCEPT_KEYWORDS="amd64"

L10N="en-US zh-CN"

PORTAGE_TMPDIR='/tmp'
BUILD_PREFIX='/tmp/portage'

PORTDIR="/usr/portage"
DISTDIR="${PORTDIR}/distfiles"
PKGDIR="${PORTDIR}/packages"
PORTAGE_ELOG_CLASSES="info warn error log qa"
PORTAGE_ELOG_SYSTEM="save"
MAKECONF

# Dynamic values (uses variables, so append separately)
{
    echo ""
    echo "MAKEOPTS=\"-j${JOBS}\""
    echo "GENTOO_MIRRORS=\"${GENTOO_MIRROR}\""
} >> "${MOUNT_POINT}/etc/portage/make.conf"

#######################################
# Step 6: Configure DNS and chroot prep
#######################################
info "Step 6: Preparing chroot environment..."

cp -L /etc/resolv.conf "${MOUNT_POINT}/etc/"

mountpoint -q "${MOUNT_POINT}/proc" 2>/dev/null || mount --types proc /proc "${MOUNT_POINT}/proc"
if ! mountpoint -q "${MOUNT_POINT}/sys" 2>/dev/null; then
    mount --rbind /sys "${MOUNT_POINT}/sys"
    mount --make-rslave "${MOUNT_POINT}/sys"
fi
if ! mountpoint -q "${MOUNT_POINT}/dev" 2>/dev/null; then
    mount --rbind /dev "${MOUNT_POINT}/dev"
    mount --make-rslave "${MOUNT_POINT}/dev"
fi
if ! mountpoint -q "${MOUNT_POINT}/run" 2>/dev/null; then
    mount --bind /run "${MOUNT_POINT}/run"
    mount --make-slave "${MOUNT_POINT}/run"
fi

#######################################
# Step 7: Generate fstab
#######################################
info "Step 7: Generating fstab..."

EFI_UUID=$(blkid -s UUID -o value "${EFI_PART}")
ROOT_UUID=$(blkid -s UUID -o value "${ROOT_PART}")

cat > "${MOUNT_POINT}/etc/fstab" << FSTAB
# <fs>          <mountpoint>    <type>      <opts>                          <dump/pass>
UUID=${ROOT_UUID}   /           xfs     noatime,discard,allocsize=64k,inode64,logbufs=8,logbsize=256k   0 0
UUID=${EFI_UUID}    /boot/efi   vfat    noauto,defaults                     0 0
FSTAB

#######################################
# Step 8: Copy kernel config
#######################################
info "Step 8: Preparing kernel config..."

if [[ -n "${KERNEL_CONFIG_URL:-}" ]]; then
    wget -O "${MOUNT_POINT}/tmp/kernel.config" "${KERNEL_CONFIG_URL}"
else
    if [[ -f "${KERNEL_CONFIG_FILE}" ]]; then
        cp "${KERNEL_CONFIG_FILE}" "${MOUNT_POINT}/tmp/kernel.config"
    else
        warn "No kernel config found, will use default"
        touch "${MOUNT_POINT}/tmp/kernel.config"
    fi
fi

#######################################
# Step 9: Copy nvim config
#######################################
info "Step 9: Copying nvim config..."

if [[ -f "${SCRIPT_DIR}/nvim/init.vim" ]]; then
    mkdir -p "${MOUNT_POINT}/tmp/gentoo_setup_files"
    cp "${SCRIPT_DIR}/nvim/init.vim" "${MOUNT_POINT}/tmp/gentoo_setup_files/"
fi

#######################################
# Step 10: Copy htop config
#######################################
info "Step 10: Copying htop config..."

if [[ -f "${SCRIPT_DIR}/htop/htoprc" ]]; then
    mkdir -p "${MOUNT_POINT}/tmp/gentoo_setup_files"
    cp "${SCRIPT_DIR}/htop/htoprc" "${MOUNT_POINT}/tmp/gentoo_setup_files/"
fi

#######################################
# Step 11: Copy zshrc files
#######################################
info "Step 11: Copying zshrc files..."

if [[ -f "${SCRIPT_DIR}/shell/zshrc" ]]; then
    cp "${SCRIPT_DIR}/shell/zshrc" "${MOUNT_POINT}/tmp/gentoo_setup_files/zshrc"
fi
if [[ -f "${SCRIPT_DIR}/shell/zshrc_root" ]]; then
    cp "${SCRIPT_DIR}/shell/zshrc_root" "${MOUNT_POINT}/tmp/gentoo_setup_files/zshrc_root"
fi

#######################################
# Step 12: Create chroot script
#######################################
info "Step 12: Creating chroot installation script..."

cat > "${MOUNT_POINT}/tmp/chroot_install.sh" << 'CHROOT_SCRIPT'
#!/bin/bash
set -euo pipefail

info()  { echo -e "\033[1;32m>>> $*\033[0m"; }
warn()  { echo -e "\033[1;33m!!! $*\033[0m"; }
error() { echo -e "\033[1;31mERROR: $*\033[0m" >&2; exit 1; }

# Variables passed via environment
TIMEZONE="${TIMEZONE}"
HOSTNAME="${HOSTNAME}"
ROOT_PASSWORD="${ROOT_PASSWORD}"
SSH_PORT="${SSH_PORT}"
USER_NAME="${USER_NAME}"
USER_PASSWORD="${USER_PASSWORD}"
EFI_PART="${EFI_PART}"
TARGET_DISK="${TARGET_DISK}"
JOBS="${JOBS}"

#--- Reload environment ---
info "[chroot] Reloading environment..."
set +u
source /etc/profile
set -u
export PS1="(chroot) ${PS1:-# }"

#--- Mount boot ---
mount /boot/efi 2>/dev/null || true

#--- Sync portage ---
info "[chroot] Syncing portage tree..."
emerge-webrsync

#--- Select profile (interactive) ---
info "[chroot] Available profiles:"
eselect profile list
echo ""
read -rp "Enter profile number: " PROFILE_NUM
eselect profile set "${PROFILE_NUM}"
info "[chroot] Selected profile #${PROFILE_NUM}"

#--- Timezone ---
info "[chroot] Setting timezone to ${TIMEZONE}..."
echo "${TIMEZONE}" > /etc/timezone
emerge --config sys-libs/timezone-data

#--- Locale ---
info "[chroot] Configuring locale..."
cat > /etc/locale.gen << 'LOCALE'
en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
LOCALE
locale-gen
eselect locale set en_US.utf8 2>/dev/null || eselect locale set en_US.UTF-8 2>/dev/null || true
env-update
set +u; source /etc/profile; set -u

#--- Update @world ---
info "[chroot] Updating @world (this may take a while)..."
emerge -q --update --deep --newuse @world || true

#--- Install kernel sources ---
info "[chroot] Installing kernel sources..."
emerge -q sys-kernel/gentoo-sources sys-kernel/linux-firmware

#--- Compile kernel ---
info "[chroot] Compiling kernel..."
KERNEL_SRC=$(find /usr/src -maxdepth 1 -name 'linux-*' -type d | sort -V | tail -1)
[[ -d "${KERNEL_SRC}" ]] || error "No kernel source found in /usr/src"

cd "${KERNEL_SRC}"

if [[ -s /tmp/kernel.config ]]; then
    cp /tmp/kernel.config .config
    # Adapt old config to new kernel version
    make olddefconfig
else
    make defconfig
fi

info "[chroot] Building kernel with -j${JOBS}..."
make -j${JOBS}
make modules_install
make install

#--- Generate initramfs with dracut ---
info "[chroot] Generating initramfs (for microcode and clean boot)..."
emerge -q sys-kernel/dracut

KERNEL_VERSION=$(basename "${KERNEL_SRC}" | sed 's/linux-//')
dracut --force /boot/initramfs-${KERNEL_VERSION}.img ${KERNEL_VERSION}
info "[chroot] initramfs generated: /boot/initramfs-${KERNEL_VERSION}.img"

#--- Install and configure GRUB ---
info "[chroot] Installing GRUB bootloader..."
emerge -q sys-boot/grub

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Gentoo

# Generate GRUB config
grep -q '^GRUB_TIMEOUT=' /etc/default/grub 2>/dev/null || echo 'GRUB_TIMEOUT=3' >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

info "[chroot] GRUB boot configured with initramfs."

#--- Install essential packages ---
info "[chroot] Installing essential packages..."
emerge -q \
    sys-fs/xfsprogs \
    sys-fs/dosfstools \
    app-editors/neovim \
    app-shells/zsh \
    sys-apps/mlocate \
    net-misc/dhcpcd \
    net-misc/openssh \
    dev-vcs/git \
    sys-process/htop \
    app-misc/tmux \
    sys-apps/pciutils \
    sys-apps/usbutils \
    app-portage/eix \
    app-portage/gentoolkit

#--- Configure SSH ---
info "[chroot] Configuring SSH..."
sed -i "s/^#Port 22/Port ${SSH_PORT}/" /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

#--- Enable services ---
info "[chroot] Enabling services..."
rc-update add sshd default
rc-update add dhcpcd default

#--- Set hostname ---
info "[chroot] Setting hostname to ${HOSTNAME}..."
echo "hostname=\"${HOSTNAME}\"" > /etc/conf.d/hostname

#--- Configure network (interactive, per-interface) ---
info "[chroot] Configuring network..."

cat > /etc/conf.d/net << 'NETHEAD'
# Auto-generated by install_gentoo.sh
NETHEAD

ALL_IFS=$(ls /sys/class/net/ 2>/dev/null | grep -vE '^lo$' | sort)

if [[ -z "${ALL_IFS}" ]]; then
    warn "[chroot] No network interfaces detected, skipping"
else
    for iface in ${ALL_IFS}; do
        echo ""
        info "Interface: ${iface}"
        echo "  [1] dhcp (default)"
        echo "  [2] static"
        echo "  [3] none (skip)"
        read -rp "  Choose [1/2/3]: " choice
        choice="${choice:-1}"

        case "${choice}" in
            2)
                read -rp "  IP address (e.g. 192.168.1.100/24): " static_ip
                read -rp "  Gateway    (e.g. 192.168.1.1):      " static_gw
                read -rp "  DNS        (e.g. 8.8.8.8):          " static_dns
                cat >> /etc/conf.d/net << STATICCONF

config_${iface}="${static_ip}"
routes_${iface}="default via ${static_gw}"
dns_servers_${iface}="${static_dns}"
STATICCONF
                ;;
            3)
                info "  Skipping ${iface}"
                continue
                ;;
            *)
                echo "config_${iface}=\"dhcp\"" >> /etc/conf.d/net
                ;;
        esac

        cd /etc/init.d
        ln -sf net.lo "net.${iface}" 2>/dev/null || true
        rc-update add "net.${iface}" default 2>/dev/null || true
    done
fi

#--- Set root password ---
info "[chroot] Setting root password..."
echo "root:${ROOT_PASSWORD}" | chpasswd

#--- Allow weak passwords ---
if [[ -f /etc/security/passwdqc.conf ]]; then
    sed -i 's/^enforce=.*/enforce=none/' /etc/security/passwdqc.conf
    grep -q '^enforce=' /etc/security/passwdqc.conf || echo 'enforce=none' >> /etc/security/passwdqc.conf
fi

#--- Create non-root user ---
info "[chroot] Creating user ${USER_NAME}..."
useradd -m -G wheel,audio,video,portage,usb -s /bin/zsh "${USER_NAME}" 2>/dev/null || true
echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd

#--- Set root shell to zsh ---
chsh -s /bin/zsh root

#--- Deploy zshrc ---
info "[chroot] Deploying zsh configs..."
if [[ -f /tmp/gentoo_setup_files/zshrc_root ]]; then
    cp /tmp/gentoo_setup_files/zshrc_root /root/.zshrc
fi
if [[ -f /tmp/gentoo_setup_files/zshrc ]]; then
    cp /tmp/gentoo_setup_files/zshrc "/home/${USER_NAME}/.zshrc"
    chown "${USER_NAME}:${USER_NAME}" "/home/${USER_NAME}/.zshrc"
fi

#--- Deploy nvim config ---
info "[chroot] Deploying nvim config..."
mkdir -p /root/.config/nvim
mkdir -p "/home/${USER_NAME}/.config/nvim"

if [[ -f /tmp/gentoo_setup_files/init.vim ]]; then
    cp /tmp/gentoo_setup_files/init.vim /root/.config/nvim/init.vim
    cp /tmp/gentoo_setup_files/init.vim "/home/${USER_NAME}/.config/nvim/init.vim"
    chown -R "${USER_NAME}:${USER_NAME}" "/home/${USER_NAME}/.config"
fi

# Link nvim as vim
ln -sf /usr/bin/nvim /usr/local/bin/vim 2>/dev/null || true

#--- Deploy htop config ---
info "[chroot] Deploying htop config..."
if [[ -f /tmp/gentoo_setup_files/htoprc ]]; then
    mkdir -p /root/.config/htop
    mkdir -p "/home/${USER_NAME}/.config/htop"
    cp /tmp/gentoo_setup_files/htoprc /root/.config/htop/htoprc
    cp /tmp/gentoo_setup_files/htoprc "/home/${USER_NAME}/.config/htop/htoprc"
    chown -R "${USER_NAME}:${USER_NAME}" "/home/${USER_NAME}/.config/htop"
fi

#--- Write /etc/motd and /usr/local/etc/gentoo-tips ---
info "[chroot] Writing /etc/motd and /usr/local/etc/gentoo-tips..."
cat > /etc/motd << 'MOTD'
  Gentoo tips & cheatsheet: cat /usr/local/etc/gentoo-tips
MOTD

cat > /usr/local/etc/gentoo-tips << 'TIPS'
=============== Gentoo Quick Reference ===============

--- Network (OpenRC + netifrc) ---

  Config:  /etc/conf.d/net

  DHCP:    config_eth0="dhcp"
  Static:  config_eth0="192.168.1.100/24"
           routes_eth0="default via 192.168.1.1"
           dns_servers_eth0="8.8.8.8"

  Apply:   rc-service net.<iface> restart
  Add if:  cd /etc/init.d && ln -sf net.lo net.<iface>
           rc-update add net.<iface> default

--- Package management ---

  Search:          eix <keyword>
  Install:         emerge -avq <pkg>
  Uninstall:       emerge -avq --depclean <pkg>
  Update world:    emerge -avquDN @world
  Sync tree:       emerge --sync

--- Dependency & reverse-dependency ---

  Why installed:   equery depends <pkg>    (who depends on <pkg>)
  Deps of pkg:     equery depgraph <pkg>   (what <pkg> depends on)
  Dep tree:        emerge -avqp --tree <pkg>
  Orphan pkgs:     emerge --depclean -p    (preview unused deps)
  Clean orphans:   emerge --depclean

--- USE flags ---

  Active flags:    equery uses <pkg>
  What uses flag:  equery hasuse <flag>
  Per-pkg flags:   /etc/portage/package.use/

--- Kernel ---

  Rebuild:         cd /usr/src/linux && make -j$(nproc) && make modules_install && make install
  Initramfs:       dracut --force /boot/initramfs-$(uname -r).img $(uname -r)
  Update GRUB:     grub-mkconfig -o /boot/grub/grub.cfg
  Module info:     modinfo <module>

--- Services (OpenRC) ---

  List:            rc-status
  Start/stop:      rc-service <svc> start|stop|restart
  Enable/disable:  rc-update add|del <svc> default

--- Useful files ---

  Portage config:  /etc/portage/make.conf
  Installed pkgs:  /var/lib/portage/world
  Build logs:      /var/tmp/portage/

======================================================
TIPS

#--- Create dev directory for user ---
mkdir -p "/home/${USER_NAME}/dev"
chown "${USER_NAME}:${USER_NAME}" "/home/${USER_NAME}/dev"

#--- Update eix database ---
info "[chroot] Updating eix database..."
eix-update

#--- Cleanup ---
info "[chroot] Cleaning up..."
rm -rf /tmp/gentoo_setup_files
rm -f /tmp/kernel.config
rm -f /tmp/chroot_install.sh

info "[chroot] ========================================="
info "[chroot]  Gentoo installation complete!"
info "[chroot]  Hostname : ${HOSTNAME}"
info "[chroot]  SSH Port : ${SSH_PORT}"
info "[chroot]  User     : ${USER_NAME}"
info "[chroot]  Tips     : cat /usr/local/etc/gentoo-tips"
info "[chroot] ========================================="
CHROOT_SCRIPT

chmod +x "${MOUNT_POINT}/tmp/chroot_install.sh"

#######################################
# Step 13: Execute chroot
#######################################
info "Step 13: Entering chroot and running installation..."

chroot "${MOUNT_POINT}" /bin/bash -c "
    export TIMEZONE='${TIMEZONE}'
    export HOSTNAME='${HOSTNAME}'
    export ROOT_PASSWORD='${ROOT_PASSWORD}'
    export SSH_PORT='${SSH_PORT}'
    export USER_NAME='${USER_NAME}'
    export USER_PASSWORD='${USER_PASSWORD}'
    export EFI_PART='${EFI_PART}'
    export TARGET_DISK='${TARGET_DISK}'
    export JOBS='${JOBS}'
    /tmp/chroot_install.sh
"

#######################################
# Step 14: Unmount and finish
#######################################
info "Step 14: Unmounting..."

umount -l "${MOUNT_POINT}/dev"{/shm,/pts,} 2>/dev/null || true
umount -l "${MOUNT_POINT}/run" 2>/dev/null || true
umount -l "${MOUNT_POINT}/proc" 2>/dev/null || true
umount -l "${MOUNT_POINT}/sys" 2>/dev/null || true
umount -l "${MOUNT_POINT}/boot/efi" 2>/dev/null || true
umount -l "${MOUNT_POINT}" 2>/dev/null || true

echo ""
info "=============================================="
info "  Installation complete!"
info "  Remove the USB drive and reboot:"
info "    reboot"
info ""
info "  After reboot, SSH into the machine:"
info "    ssh ${USER_NAME}@<IP> -p ${SSH_PORT}"
info "=============================================="
