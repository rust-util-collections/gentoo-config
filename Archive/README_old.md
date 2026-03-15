## Gentoo
[Welcome to Gentoo, a highly flexible, source-based Linux distribution.](https://gentoo.org/)

## Example installation: MacBook Pro 15" 2015 Early
0. In Mac OS X, set volume to 0 to avoid startup chime issues after switching to Linux
1. Partitioning and chroot
```
mkfs.vfat -F 32 /dev/sda1
mkfs.f2fs /dev/sda2

mkdir -p /mnt/gentoo
mount /dev/sda2 /mnt/gentoo
cd /mnt/gentoo

mount -t proc /proc proc/
mount --rbind /sys sys/
mount --rbind /dev dev/
chroot . /bin/bash
export PATH=/usr/bin:/usr/sbin:/bin:/sbin
source /etc/profile
```
2. **Set root password**
3. Basic environment configuration
```
cp gentoo_config/MacBook_special/make.conf /etc/portage/make.conf
cp gentoo_config/MacBook_special/fstab /etc/fstab
```
4. Update base system
```
emerge-webrsync
eselect profile set default/linux/amd64/17.1/desktop (stable)
emerge -avquDN --with-bdeps=y @world && emerge -c
```
5. Install gentoo-sources, configure and compile kernel
```
cp gentoo_config/MacBook_special/kernel_config /usr/src/linux/.config
cd /usr/src/linux
make -j9
make modules_install
cp -L arch/x86_64/boot/bzImage /boot/efi/bootx64.efi
```
6. Install efibootmgr and add EFI boot entry
```
emerge -avq efibootmgr
efibootmgr -c -d /dev/sda -p 1 -L gentoo -l "bootx64.efi"
```
7. Minimal xfce desktop installation

> The default notify daemon shows errors when adjusting brightness, install xfce4-notifyd instead;
> With sound disabled globally, alsa-lib is required to launch vscode.

```
emerge -avq xorg-server xfwm4 xfdesktop xfce4-session xfce4-settings xfce4-terminal xfce4-notifyd alsa-lib networkmanager
```
8. Connect to WiFi
- Home network
```
nmcli device wifi list
nmcli device wifi connect $SSID password $PASSWORD
```
- 802.1X enterprise network
See this article:
[https://major.io/2016/05/03/802-1x-networkmanager-using-nmcli](https://major.io/2016/05/03/802-1x-networkmanager-using-nmcli)
Or temporarily install nm-applet suite, use nm-connection-editor to create config, then uninstall it
```
cp gentoo_config/wifi_cfg /etc/NetworkManager/system-connections/
```
9. Thermal management and temperature control
```
emerge -avq lm_sensors mbpfan
sensors-detect
systemctl enable --now lm_sensors
systemctl enable --now mbpfan
```
10. Set up development environment
```
echo "app-editors/vim -X python" >> /etc/portage/package.use/vim
emerge -avq vim zsh google-chrome go dev-vcs/git
chsh -s /bin/zsh $USENAME

# C/rust/go development: vim with YouCompleteMe
# LaTeX development: vscode with latex workshop plugin

# golang env
export GO111MODULE=on
export GOPROXY=https://goproxy.cn  # China proxy provided by Qiniu

# rust env
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
```
11. Configure hotkeys
```
cp MBP_special/kbctl.sh /root/
cp MBP_special/kbctl.service /lib/systemd/system/
cp -r MBP_special/home_bin ~/.bin
systemctl enable --now kbctl.service

emerge -avq xbindkeys
cp gentoo_config/xbindkeysrc ~/.xbindkeysrc
echo -e "xbindkeys \n exec startxfce4" > ~/.xinitrc
```
12. Set ALSA default sound card
```
aplay -l # List sound cards

echo "defaults.pcm.card 1
defaults.pcm.device 0
defaults.ctl.card 1" >> /etc/asound.conf
```
13. Update microcode without initramfs
```
[        0.000000] [Firmware Bug]: TSC_DEADLINE disabled due to Errata; please update microcode to version: 0x22 (or later)
```
Linux kernel can dynamically load CPU microcode at each boot without hardware update. If you see errors like above, refer to this wiki:
<https://wiki.gentoo.org/wiki/Intel_microcode#New_method_without_initram-fs.2Fdisk>

Verify the update:
```
grep microcode /proc/cpuinfo
dmesg | grep -in microcode
```
Example output:
```
microcode	: 0x25
microcode	: 0x25
microcode	: 0x25
microcode	: 0x25
microcode	: 0x25
microcode	: 0x25
microcode	: 0x25
microcode	: 0x25
[    0.000000] microcode: microcode updated early to revision 0x25, date = 2018-04-02
[    0.394453] microcode: sig=0x306c3, pf=0x2, revision=0x25
[    0.394599] microcode: Microcode Update Driver: v2.2.
```
