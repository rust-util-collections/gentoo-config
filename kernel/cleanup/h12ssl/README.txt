Kernel Config Cleanup Scripts — H12SSL (EPYC 7003 / 7773x)
===========================================================
Target: EPYC_7773x_supermicro_h12_ssl
Scope:  Headless dev server, no KVM, no containers, no perf/bpftrace, nftables only

与 H13SSL (9004) 的主要差异
----------------------------
  - 7003 config 本身已无 iptables / ip6tables / IP_VS / IP_SET
  - 7003 config 本身已无 FIREWIRE / ATM / ACPI_DOCK / KUnit / torture test
  - 7003 有独特的遗留项: IP_PNP, IIO, AMD_SFH_HID
  - 7003 crypto 更精简，仅需去除 DES / ARC4 / ECHAINIV
  - Tier 01 在此 config 上为空操作 (原 config 无测试选项)

Tier    内容                            风险    预计删除项
----    ----                            ----    ----------
01      纯测试代码 (7003 本身无)        零      0
02      调试开销 (DEBUG_INFO/SLUB等)    极低    ~6
03      死硬件/无用驱动/IP_PNP          低      ~12 (+级联)
04      KVM/虚拟化                      低      ~3 (+级联)
05      Tracing/Profiling + Intel RAPL  中低    ~6 (+级联)
06      Netfilter 精简                  中      ~35 (+级联)
07      Crypto 精简 (DES/ARC4/ECHAINIV) 中      ~4 (+级联)
                                                --------
                                        合计    ~66 直接 + 级联

使用方法
--------
  # 方式一: 逐 tier 应用 (推荐)
  cp ../../EPYC_7773x_supermicro_h12_ssl /usr/src/linux/.config
  ./01-remove-tests.sh    /usr/src/linux/.config
  cd /usr/src/linux && make olddefconfig && make -j$(nproc)
  # 重启测试，确认没问题后继续下一个 tier
  ./02-remove-debug.sh    /usr/src/linux/.config
  cd /usr/src/linux && make olddefconfig && make -j$(nproc)
  # ... 以此类推 ...

  # 方式二: 一键全部应用 (仅在逐 tier 都验证过后使用)
  cp ../../EPYC_7773x_supermicro_h12_ssl /usr/src/linux/.config
  ./apply-all.sh /usr/src/linux/.config
  cd /usr/src/linux && make olddefconfig && make -j$(nproc)

注意事项
--------
  - 每个 tier 脚本可多次运行，已禁用的选项会被跳过 (幂等)
  - make olddefconfig 会自动清理因父选项禁用而级联失效的子选项
  - Tier 06 后务必测试 nftables 规则加载
  - Tier 07 后务必测试 SSH 登录 + HTTPS 连接
  - AES_NI_INTEL / GHASH_CLMUL_NI_INTEL / SHA*_SSSE3 在 AMD 平台同样有效，
    这些选项特意保留以获得硬件加速
  - IP_PNP 删除后，网络配置完全依赖 userspace (dhcpcd / static)，
    initramfs 中若无网络工具则无法在 early boot 拿到 IP，通常影响不大
