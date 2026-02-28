#!/usr/bin/env bash
# =============================================================================
# Tier 06 - Netfilter 精简 (仅保留 nftables 核心)
#
# 针对 EPYC_7773x_supermicro_h12_ssl，7003 config 已无 iptables / ip6tables /
# IP_VS / IP_SET，比 9004 轻得多。主要清理:
#   - BRIDGE + 相关 (无容器/桥接)
#   - VLAN_8021Q / IPVLAN / MACVLAN (无 VLAN/容器虚拟网络)
#   - NF_FLOW_TABLE 系列 (流量卸载，路由器功能，服务器不需要)
#   - NF_DUP / NF_SOCKET / NF_TPROXY (包复制/透明代理)
#   - NFT 扩展模块: SYNPROXY / TUNNEL / XFRM / QUEUE / QUOTA /
#                   HASH / NUMGEN / OSF / SOCKET / TPROXY /
#                   FLOW_OFFLOAD / DUP / FWD_NETDEV / FIB_NETDEV
#   - NETFILTER_NETLINK 附属: ACCT / OSF / QUEUE
#   - NETFILTER_SYNPROXY / CONNCOUNT
#   - NF_CONNTRACK 杂项: LABELS / PROCFS (基础 conntrack 本身保留)
#
# 保留: NF_TABLES + INET/IPV4/IPV6/ARP, NF_CONNTRACK (core), NF_NAT (core),
#       NF_NAT_MASQUERADE, NFT_CT/LOG/LIMIT/COUNTER/CONNLIMIT,
#       NFT_NAT/MASQ/REJECT(+INET/IPV4/IPV6), NFT_FIB(+INET/IPV4/IPV6),
#       NF_REJECT_IPV4/IPV6, NF_DEFRAG_IPV4/IPV6, NF_LOG_*,
#       NETFILTER_NETLINK / NETLINK_LOG / NETFILTER_INGRESS,
#       NETFILTER_FAMILY_ARP
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/00-common.sh"

echo "[Tier 06] Stripping netfilter to nftables-only..."

# --- Bridge 子系统 (无容器/桥接) ---
# 级联消失: BRIDGE_IGMP_SNOOPING / BRIDGE_VLAN_FILTERING /
#           NF_TABLES_BRIDGE / NFT_BRIDGE_META / NFT_BRIDGE_REJECT /
#           NETFILTER_FAMILY_BRIDGE
disable_opt CONFIG_BRIDGE
disable_opt CONFIG_NF_TABLES_BRIDGE

# --- Per-device nftables hooks (无 NETDEV 层过滤需求) ---
# 级联消失: NFT_DUP_NETDEV / NFT_FWD_NETDEV / NFT_FIB_NETDEV
disable_opt CONFIG_NF_TABLES_NETDEV

# --- VLAN / 虚拟网络接口 (无 VLAN/容器虚拟网络) ---
disable_opt CONFIG_VLAN_8021Q
disable_opt CONFIG_IPVLAN
# IPVLAN_L3S 会随 IPVLAN 级联消失
disable_opt CONFIG_MACVLAN

# --- Flow table 流量卸载 (路由器/NAT box 功能，服务器不需要) ---
disable_opt CONFIG_NF_FLOW_TABLE
disable_opt CONFIG_NF_FLOW_TABLE_INET
disable_opt CONFIG_NF_FLOW_TABLE_IPV4
disable_opt CONFIG_NF_FLOW_TABLE_IPV6
disable_opt CONFIG_NFT_FLOW_OFFLOAD

# --- 包复制 ---
disable_opt CONFIG_NF_DUP_IPV4
disable_opt CONFIG_NF_DUP_IPV6
disable_opt CONFIG_NF_DUP_NETDEV
disable_opt CONFIG_NFT_DUP_IPV4
disable_opt CONFIG_NFT_DUP_IPV6
disable_opt CONFIG_NFT_DUP_NETDEV

# --- 透明代理 / Socket 匹配 ---
disable_opt CONFIG_NF_SOCKET_IPV4
disable_opt CONFIG_NF_SOCKET_IPV6
disable_opt CONFIG_NF_TPROXY_IPV4
disable_opt CONFIG_NF_TPROXY_IPV6
disable_opt CONFIG_NFT_SOCKET
disable_opt CONFIG_NFT_TPROXY

# --- SYN proxy ---
disable_opt CONFIG_NETFILTER_SYNPROXY
disable_opt CONFIG_NFT_SYNPROXY

# --- 不需要的 nftables 扩展模块 ---
disable_opt CONFIG_NFT_TUNNEL       # GRE/VXLAN 隧道
disable_opt CONFIG_NFT_XFRM        # IPsec 集成
disable_opt CONFIG_NFT_QUEUE        # 用户态 nfqueue
disable_opt CONFIG_NFT_QUOTA        # 配额管理
disable_opt CONFIG_NFT_HASH         # hash 数据结构 (load balance 用)
disable_opt CONFIG_NFT_NUMGEN       # 数字生成 (load balance 用)
disable_opt CONFIG_NFT_OSF          # OS 指纹识别
disable_opt CONFIG_NFT_OBJREF       # 命名对象引用
disable_opt CONFIG_NFT_REDIR        # 端口重定向 (透明代理)
disable_opt CONFIG_NFT_FWD_NETDEV   # per-device 转发 (随 NF_TABLES_NETDEV 消失)
disable_opt CONFIG_NFT_FIB_NETDEV   # per-device FIB (随 NF_TABLES_NETDEV 消失)

# --- NETFILTER_NETLINK 附属模块 ---
disable_opt CONFIG_NETFILTER_NETLINK_ACCT   # 流量计费
disable_opt CONFIG_NETFILTER_NETLINK_OSF    # OS 指纹
disable_opt CONFIG_NETFILTER_NETLINK_QUEUE  # 用户态队列
disable_opt CONFIG_NETFILTER_CONNCOUNT      # 连接数统计 (nft connlimit 用 NFT_CONNLIMIT 替代)

# --- Conntrack 杂项 (保留 NF_CONNTRACK core / MARK) ---
disable_opt CONFIG_NF_CONNTRACK_LABELS   # 标签 (容器/策略路由用)
disable_opt CONFIG_NF_CONNTRACK_PROCFS   # 传统 /proc/net/ip_conntrack 接口

count_after=$(grep -c '=y\|=m' "$CONFIG" || true)
echo "[Tier 06] Done. $((count_before - count_after)) options disabled."
echo "          Next: cd /usr/src/linux && make olddefconfig && make -j\$(nproc)"
echo "          IMPORTANT: 应用后务必测试 nftables 规则是否正常加载!"
