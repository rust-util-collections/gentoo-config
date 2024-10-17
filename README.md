# gentoo-config

#### <1> VIM nerd_tree 侧栏乱码问题:

```shell
#
# 注释掉不能显示的富文本字体
# vim /usr/local/share/vim/vim74/plugin/NERD_tree.vim
#

"if !nerdtree#runningWindows() && !nerdtree#runningCygwin()
"    call s:initVariable('g:NERDTreeDirArrowExpandable', '▸')
"    call s:initVariable('g:NERDTreeDirArrowCollapsible', '▾')
"else
    call s:initVariable('g:NERDTreeDirArrowExpandable', '+')
    call s:initVariable('g:NERDTreeDirArrowCollapsible', '~')
"endif
```

#### <2> 禁用 ubuntu Dock 栏

> SEE ALSO: https://linux.cn/article-10170-1.html

```
gsettings set org.gnome.shell.extensions.dash-to-dock autohide false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false
```

#### <3> YouCompleteMe 'runtime error'

```shell
rustup component add rust-src
rustup component add rust-src --toolchain nightly

cd YouCompleteMe
perl -pi -e 's/RUST_TOOLCHAIN\s*=.*/RUST_TOOLCHAIN = "nightly"/g' third_party/ycmd/build.py

./install.py --rust-completer --go-completer
```

#### <4> Change passwd rules

`man passwdqc.conf`

```shell
# /etc/security/passwdqc.conf
enforce = none
```

#### <5> Crossdev compiling

- **https://wiki.gentoo.org/wiki/Crossdev**
- [**/usr/x86_64-unknown-linux-musl/etc/portage/make.conf**](usr_x86_64-unknown-linux-musl_etc_portage_make.conf)

```shell
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

#### <6> YouCompleteMe on Alpine(musl)

Issue (`install.py --rust-completer --go-completer`):

```shell
/home/fh/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/absl/absl/base/internal/spinlock_linux.inc:17:10: fatal error: linux/futex.h: No such file or directory
   17 | #include <linux/futex.h>
      |          ^~~~~~~~~~~~~~~
compilation terminated.
make[3]: *** [absl/absl/base/CMakeFiles/absl_spinlock_wait.dir/build.make:76: absl/absl/base/CMakeFiles/absl_spinlock_wait.dir/internal/spinlock_wait.cc.o] Error 1
make[2]: *** [CMakeFiles/Makefile2:602: absl/absl/base/CMakeFiles/absl_spinlock_wait.dir/all] Error 2
make[2]: *** Waiting for unfinished jobs....
```

Solution:

```shell
apk add linux-headers
```

#### <7> Clean unneed packages on opensuse

```shell
# add this alias to '/root/.bashrc' or '/root/.zshrc'
alias clean="zypper packages --unneeded | awk -F'|' 'NR==0 || NR==1 || NR==2 || NR==3 || NR==4 {next} {print \$3}' | grep -v Name | xargs zypper remove --clean-deps"
```

#### <8> Colorful git-diff on Alpine linux

```shell
apk add git-diff-highlight
# and then, re-login
```

#### <9> MUSL platform: "rustc: Dynamic loading not supported"

> disable the default feature of 'static link'

```shell
# ~/.bashrc or ~/.zshrc
export RUSTFLAGS="-C target-feature=-crt-static"
```

#### <10> Allow setting weak password

```shell
# vi /etc/security/passwdqc.conf
enforce=none
```

#### <11> Docker modulers on gentoo

```shell
modprobe tun

modprobe br_netfilter
modprobe iptable_filter

modprobe nf_nat
modprobe iptable_nat
modprobe xt_nat

modprobe nf_conntrack
modprobe xt_conntrack

modprobe xt_MASQUERADE
modprobe xt_addrtype
```

#### <12> Github/Google network settings

[**World-wide network settings**](./github_google.md)

#### <13> Major installing steps of the 'Gentoo Linux'

```shell
parted -a optimal /dev/...
mkfs.vfat -F 32 ...
mkfs.btrfs ...

wget https://.../...stage3.tar.gz
tar -xpf ...stage3.tar.gz

chroot ...

blkid >> /etc/fstab
vi /etc/fstab

mount -a

# config and compile kernel
make -jN
make modules_install
make install

# # initramfs
# dracut --hostonly --force

grub-install --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

vi /etc/portage/make.conf
emerge-websync
eselect profile set N

emerge linux-firmware

emerge dhcpcd
systemctl enable dhcpcd

passwd root

reboot

# if reboot failed, try remove the initramfs file,
# and `grub-mkconfig -o /boot/grub/grub.cfg`;
# if this works, then `emerge -C installkernel` is a good idea.
```
