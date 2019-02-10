CFLAGS="-march=znver3 -O2 -pipe"
CXXFLAGS="${CFLAGS}"
MAKEOPTS="-j24"
CHOST="x86_64-pc-linux-gnu"

# USE="lto systemd -elogind -consolekit X opengl gtk gtk3 truetype jpeg png ttf opengl -ffmpeg -sound -pulseaudio -alsa -bluetooth -wifi -wext -networkmanager -iptables -firewalld -multilib -tcpd -gpm -cdda -udisks -cups -emoji -calendar -sftp -samba -vlc -ldap -doc -gnome -kde -qt -qt4 -qt5 -http -debug"

USE="lto systemd -multilib -elogind -consolekit -X -wayland -iptables -firewalld -tcpd -gpm -cdda -sftp -tftp -ftp -pop3 -smtp -samba -ldap -doc -debug"

CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt sse sse2 sse3 sse4_1 sse4_2 sse4a ssse3"

FEATURES="splitdebug"

ABI_X86="64"
GRUB_PLATFORMS="efi-64"

QEMU_USER_TARGETS="x86_64"
QEMU_SOFTMMU_TARGETS="x86_64"
LLVM_TARGETS="X86 BPF WebAssembly"

ACCEPT_LICENSE="-* @FREE"
ACCEPT_KEYWORDS="amd64"

# VIDEO_CARDS="amdgpu radeonsi"
# INPUT_DEVICES="libinput"
LINGUAS="en_US.UTF-8"

PORTAGE_TMPDIR='/tmp'
GENTOO_MIRRORS="https://mirrors.ustc.edu.cn/gentoo"
BUILD_PREFIX='/tmp/portage'

PORTDIR="/usr/portage"
DISTDIR="${PORTDIR}/distfiles"
PKGDIR="${PORTDIR}/packages"
PORTAGE_ELOG_CLASSES="info warn error log qa"
PORTAGE_ELOG_SYSTEM="save"
