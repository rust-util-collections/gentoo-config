# gentoo_config

#### 安装系统
0. 分区、chroot
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
1. 为 root 设置密码
2. 配置 /etc/portage/make.conf、/etc/fstab
3. 更新基本系统
```
emerge-webrsync
emerge -avquDN --with-bdeps=y @world && emerge -c
```
4. 安装 gentoo-sources，配置、编译内核
```
cd /usr/src/linux
cp -L arch/x86_64/boot/bzImage /boot/efi/bootx64.efi
```
5. 安装 efibootmgr，添加 EFI 启动项   
```
efibootmgr -c -d /dev/sda -p 1 -L gentoo -l "bootx64.efi"
```
6. 最小化安装 xfce 桌面    
```
emerge -avq xorg-server\
			xfwm4 xfdesktop xfce4-session xfce4-settings\
			gtk-engines-xfce freedesktop-icon-theme dejavu
cd gentoo_config/
cp xinitrc ~/.xinitrc
```
7. 配置快捷键
```
emerge -avq xbindkeys
cd gentoo_config/
cp xbindkeysrc ~/.xbindkeysrc 

```
8. 配置 xterm
```
emerge -avq xterm
cd gentoo_config/
cp Xdefaults ~/.xdefaults
```
9. reboot
