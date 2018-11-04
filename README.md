## Gentoo
[Welcome to Gentoo, a highly flexible, source-based Linux distribution.](https://gentoo.org/)

## 示例安装：MacBook Pro 15ins' 2015early 
0. 在 Mac OS X 系统里，把声音调到0，以避免换装之后无法禁止的开机声音
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
2. 为 root 设置密码
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
			gtk-engines-xfce freedesktop-icon-theme dejavu
cp gentoo_config/xinitrc ~/.xinitrc
```
8. 配置快捷键
```
emerge -avq xbindkeys
cp gentoo_config/xbindkeysrc ~/.xbindkeysrc

```
9. 配置 xterm
```
emerge -avq xterm
cp gentoo_config/Xdefaults ~/.xdefaults
```
10. reboot
