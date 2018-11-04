# gentoo_config

#### 安装系统
> 安装基本系统
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
emerge -avq xorg-server xterm xfwm4 xfdesktop xfce4-session xfce4-settings gtk-engines-xfce freedesktop-icon-theme dejavu
```
7 配置快捷键

8 配置 xterm
