## Gentoo
[Welcome to Gentoo, a highly flexible, source-based Linux distribution.](https://gentoo.org/)

## 示例安装：MacBook Pro 15ins' 2015early 
0. 在 Mac OS X 系统里，把声音调到0，以避免换装 Linux 之后无法调节开机声响的问题
1. 分区、chroot
```
mkfs.vfat -F 32 /dev/sda1
mkfs.ext4 /dev/sda2

mount /dev/sda2 /mnt
cd /mnt

mount -t proc /proc proc/
mount --rbind /sys sys/
mount --rbind /dev dev/
chroot . /bin/bash
```
2. **为 root 设置密码**
3. 基本环境配置
```
cp gentoo_config/MacBook_special/make.conf /etc/portage/make.conf
cp gentoo_config/MacBook_special/fstab /etc/fstab
```
4. 更新基本系统
```
emerge-webrsync
eselect profile set default/linux/amd64/17.0/desktop (stable)
emerge -avquDN --with-bdeps=y @world && emerge -c
```
5. 安装 gentoo-sources，配置、编译内核
```
cp gentoo_config/MacBook_special/config /usr/src/linux/.config
cd /usr/src/linux
make -j9 && make modules_install
cp -L arch/x86_64/boot/bzImage /boot/efi/bootx64.efi
```
6. 安装 efibootmgr，添加 EFI 启动项   
```
emerge -avq efibootmgr
efibootmgr -c -d /dev/sda -p 1 -L gentoo -l "bootx64.efi"
```
7. 最小化安装 xfce 桌面    
```
emerge -avq xorg-server xfwm4 xfdesktop xfce4-session xfce4-settings\
			xfce4-terminal gtk-engines-xfce freedesktop-icon-theme dejavu
cp gentoo_config/xinitrc ~/.xinitrc
```
8. 连接 wifi    
- 家庭网络    
```
nmcli device wifi list
nmcli device wifi connect $SSID password $PASSWORD
```
- 802.1X 企业网络      
参考这篇文章     
[https://major.io/2016/05/03/802-1x-networkmanager-using-nmcli](https://major.io/2016/05/03/802-1x-networkmanager-using-nmcli/)     
或者可暂时安装 nm-applet 套件，使用其nm-connection-editor 编辑完配置文件后，再将其卸掉     
```
cp gentoo_config/wifi_cfg /etc/NetworkManager/system-connections/
```
9. 散热配置，温度控制
```
emerge -avq lm_sensors mbpfan
sensors-detect
systemctl enable --now lm_sensors
systemctl enable --now mbpfan
```
10. 搭建开发环境
```
echo "app-editors/vim -X python" >> /etc/portage/package.use/vim
emerge -avq vim zsh google-chrome go dev-vcs/git
chsh -s /bin/zsh $USENAME

# C/go 开发：vim，配合 YouCompleteMe
# latex 开发：vscode，安装插件 latex workshop

```
11. 配置快捷键
```
git clone https://github.com/kt10/blctl.git /tmp/
cd /tmp/blctl/

cargo build --release
mv target/release/blctl /root/
chmod +x /root/blctl

go build src/blcli
mv blcli /usr/local/bin/
chmod +x /usr/local/bin/blcli

cp gentoo_config/blctl.service /root/
ln -sv /root/blctl.service /etc/systemd/system/multi-user.target.wants/
systemctl daemon-reload
systemctl start blctl.service

emerge -avq xbindkeys
cp gentoo_config/xbindkeysrc ~/.xbindkeysrc
xbindkeys
```
12. 设置 alsa 默认声卡
```
aplay -l # 查看本机声卡信息

echo "defaults.pcm.card 1
defaults.pcm.device 1
defaults.ctl.card 1" >> /etc/asound.conf
```
13. 不使用 initramfs 更新 microcode
```
[        0.000000] [Firmware Bug]: TSC_DEADLINE disabled due to Errata; please update microcode to version: 0x22 (or later)
```
Linux 内核可以在每次启动时，动态加载 CPU 微码，从而不需要对主板进行硬更新。如果开机界面见到类似上方的错误信息，可参照如下 wiki 页面进行处理：    
<https://wiki.gentoo.org/wiki/Intel_microcode#New_method_without_initram-fs.2Fdisk>     

处理完之后，通过如下方式核对更新结果：
```
grep microcode /proc/cpuinfo
dmesg | grep -in microcode
```
结果示例：
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
