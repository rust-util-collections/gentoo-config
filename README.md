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
cd /usr/src/linux
make -j9 && make modules_install
cp -L arch/x86_64/boot/bzImage /boot/efi/bootx64.efi
```
6. 安装 efibootmgr，添加 EFI 启动项   
```
efibootmgr -c -d /dev/sda -p 1 -L gentoo -l "bootx64.efi"
```
7. 最小化安装 xfce 桌面    
```
emerge -avq xorg-server xfwm4 xfdesktop xfce4-session xfce4-settings\
			xfce4-terminal gtk-engines-xfce freedesktop-icon-theme dejavu
cp gentoo_config/xinitrc ~/.xinitrc
```
8. 配置快捷键
```
emerge -avq xbindkeys
cp gentoo_config/blctl.sh /usr/local/bin/
cp gentoo_config/xbindkeysrc ~/.xbindkeysrc

cp gentoo_config/{blctl_chmod.sh,blctl_chmod.service} /root/
ln -sv /root/blctl_chmod.service /etc/systemd/system/multi-user.target.wants/
systemctl start blctl_chmod.service
```
9. 连接 wifi    
若需连接 802.1X 企业网络，参考这篇文章    
[https://major.io/2016/05/03/802-1x-networkmanager-using-nmcli](https://major.io/2016/05/03/802-1x-networkmanager-using-nmcli/)     
```
nmcli device wifi list
nmcli device wifi connect SSID password PASSWORD
```
10. 散热配置，温度控制
```
emerge -avq lm_sensors mbpfan
sensors-detect
systemctl enable --now lm_sensors
systemctl enable --now mbpfan
```
11. 搭建开发环境
```
echo "app-editors/vim -X python" >> /etc/portage/package.use/vim
emerge -avq vim zsh google-chrome go dev-vcs/git
chsh -s /bin/zsh $USENAME

curl https://sh.rustup.rs -sSf | sh
# C/C++/go 开发：vim，配合 YouCompleteMe
# rust 开发：IntelliJ IDEA，安装插件 rust
# latex 开发：vscode，安装插件 latex workshop

```
12. 设置 alsa 默认声卡
```
aplay -l # 查看本机声卡信息

echo "defaults.pcm.card 1
defaults.pcm.device 1
defaults.ctl.card 1" >> /etc/asound.conf
```
