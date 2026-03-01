#!/usr/bin/env bash
# =============================================================================
# Tier 08 - Enable Podman (Netavark) & Pure Nftables support
#
# Enables or ensures kernel options support single-node Podman containers
# and pure nftables-based network stack.
# Completely removes dependencies on iptables/xtables and compat layers.
#
# NOTE: Must run AFTER tier 06 (depends on 00-common.sh and prior config state).
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/00-common.sh"

echo "[Tier 08] Enabling Single-Node Podman and Pure Nftables kernel options..."

# Helper functions to enable options
enable_opt_y() {
    local opt="$1"
    "${SED_INPLACE[@]}" "s/^# ${opt} is not set$/${opt}=y/" "$CONFIG"
    if ! grep -q "^${opt}=y" "$CONFIG"; then
        "${SED_INPLACE[@]}" "s/^${opt}=m$/${opt}=y/" "$CONFIG"
    fi
    if ! grep -q "^${opt}=" "$CONFIG"; then
        echo "${opt}=y" >> "$CONFIG"
    fi
}

enable_opt_m() {
    local opt="$1"
    "${SED_INPLACE[@]}" "s/^# ${opt} is not set$/${opt}=m/" "$CONFIG"
    if ! grep -q "^${opt}=m" "$CONFIG"; then
        "${SED_INPLACE[@]}" "s/^${opt}=y$/${opt}=m/" "$CONFIG"
    fi
    if ! grep -q "^${opt}=" "$CONFIG"; then
        echo "${opt}=m" >> "$CONFIG"
    fi
}

# --- Base Cgroups / Namespaces (Podman runtime foundation) ---
enable_opt_y CONFIG_NAMESPACES
enable_opt_y CONFIG_NET_NS
enable_opt_y CONFIG_USER_NS
enable_opt_y CONFIG_SECCOMP
enable_opt_y CONFIG_SECCOMP_FILTER
enable_opt_y CONFIG_CGROUPS
enable_opt_y CONFIG_CGROUP_DEVICE
enable_opt_y CONFIG_CGROUP_FREEZER
enable_opt_y CONFIG_CGROUP_CPUACCT
enable_opt_y CONFIG_CGROUP_SCHED
enable_opt_y CONFIG_BLK_CGROUP
enable_opt_y CONFIG_MEMCG
enable_opt_y CONFIG_CPUSETS

# --- Virtual Network Interfaces (Podman Netavark communication) ---
enable_opt_m CONFIG_VETH
enable_opt_m CONFIG_BRIDGE
enable_opt_m CONFIG_BRIDGE_NETFILTER
enable_opt_m CONFIG_MACVLAN
enable_opt_m CONFIG_DUMMY

# --- Storage Driver (OverlayFS is recommended) ---
enable_opt_m CONFIG_OVERLAY_FS

# --- Nftables Core (Used natively by Netavark driver) ---
# Completely abandon iptables, do not load any xt_ or ipt_ modules
enable_opt_m CONFIG_NF_TABLES
enable_opt_m CONFIG_NF_TABLES_INET
enable_opt_m CONFIG_NFT_CT
enable_opt_m CONFIG_NFT_LOG
enable_opt_m CONFIG_NFT_LIMIT
enable_opt_m CONFIG_NFT_MASQ
enable_opt_m CONFIG_NFT_NAT
enable_opt_m CONFIG_NFT_REJECT
enable_opt_m CONFIG_NF_TABLES_IPV4
enable_opt_m CONFIG_NF_TABLES_IPV6

# --- Core Connection Tracking & NAT ---
enable_opt_m CONFIG_NF_CONNTRACK
enable_opt_m CONFIG_NF_NAT

# --- Btrfs Support (If user uses Btrfs as Root) ---
enable_opt_m CONFIG_BTRFS_FS
enable_opt_y CONFIG_BTRFS_FS_POSIX_ACL

count_after=$(grep -c '=y\|=m' "$CONFIG" || true)
echo "[Tier 08] Done. Enabled essential options for pure Podman/Netavark."
