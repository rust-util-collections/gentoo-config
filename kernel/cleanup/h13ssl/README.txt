Kernel Config Cleanup Scripts — H13SSL (EPYC 9474F)
====================================================
Target: EPYC_9474F_supermicro_h13_ssl
Scope:  Headless dev server, no KVM, no containers, no perf/bpftrace, nftables only

Tier    内容                      风险    预计删除项
----    ----                      ----    ----------
01      纯测试代码 (KUnit等)      零      ~30
02      调试开销 (KGDB/DEBUG等)   极低    ~25
03      死硬件/过时协议/无用驱动  低      ~40
04      KVM/虚拟化                低      ~7 (+级联)
05      Tracing/Profiling         中低    ~15 (+级联)
06      Netfilter 精简            中      ~120
07      Crypto 精简               中高    ~60
                                          --------
                                  合计    ~320 (含级联)

使用方法
--------
  # 方式一: 逐 tier 应用 (推荐)
  cp ../../EPYC_9474F_supermicro_h13_ssl /usr/src/linux/.config
  ./01-remove-tests.sh    /usr/src/linux/.config
  cd /usr/src/linux && make olddefconfig && make -j$(nproc)
  # 重启测试，确认没问题后继续下一个 tier
  ./02-remove-debug.sh    /usr/src/linux/.config
  cd /usr/src/linux && make olddefconfig && make -j$(nproc)
  # ... 以此类推 ...

  # 方式二: 一键全部应用 (仅在逐 tier 都验证过后使用)
  cp ../../EPYC_9474F_supermicro_h13_ssl /usr/src/linux/.config
  ./apply-all.sh /usr/src/linux/.config
  cd /usr/src/linux && make olddefconfig && make -j$(nproc)

注意事项
--------
  - 每个 tier 脚本可多次运行，已禁用的选项会被跳过 (幂等)
  - make olddefconfig 会自动清理因父选项禁用而级联失效的子选项
  - Tier 06 后务必测试 nftables 规则加载
  - Tier 07 后务必测试 SSH 登录 + HTTPS 连接
