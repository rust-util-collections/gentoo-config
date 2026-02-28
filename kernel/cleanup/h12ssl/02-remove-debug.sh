#!/usr/bin/env bash
# =============================================================================
# Tier 02 - 删除调试开销 (很安全)
#
# 针对 EPYC_7773x_supermicro_h12_ssl 实际存在的调试选项:
#   DEBUG_INFO=y, DEBUG_INFO_SPLIT=y (7003 用 SPLIT，非 COMPRESSED_NONE)
#   DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y
#   DEBUG_FS_ALLOW_ALL=y → 改为 DISALLOW_MOUNT
#   SCHEDSTATS=y
#   SLUB_DEBUG=y  (运行时堆调试，生产不需要)
#
# 注: 7003 config 无 KGDB / PAGE_OWNER / PAGE_EXTENSION / DEBUG_VM /
#     SCHED_DEBUG / DEBUG_PREEMPT，这些选项在此平台本就缺席。
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/00-common.sh"

echo "[Tier 02] Removing debug overhead..."

# --- 调试符号 (省数百MB + 大幅缩短编译时间) ---
disable_opt CONFIG_DEBUG_INFO
disable_opt CONFIG_DEBUG_INFO_SPLIT                   # 7003 用此项，非 COMPRESSED_NONE
disable_opt CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT

# --- SLUB 运行时调试 ---
disable_opt CONFIG_SLUB_DEBUG

# --- 调度器统计 ---
disable_opt CONFIG_SCHEDSTATS

# --- debugfs 权限加固 (不删除 debugfs，改为默认不挂载) ---
switch_opt CONFIG_DEBUG_FS_ALLOW_ALL CONFIG_DEBUG_FS_DISALLOW_MOUNT

count_after=$(grep -c '=y\|=m' "$CONFIG" || true)
echo "[Tier 02] Done. $((count_before - count_after)) options disabled."
echo "          Next: cd /usr/src/linux && make olddefconfig && make -j\$(nproc)"
