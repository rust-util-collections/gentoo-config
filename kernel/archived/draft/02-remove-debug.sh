#!/usr/bin/env bash
# =============================================================================
# Tier 02 - 删除调试开销 (很安全)
#
# KGDB, DEBUG_INFO, 内存调试, 调度器调试, debugfs 权限加固
# 去除后编译更快、内核更小、运行时开销降低
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/00-common.sh"

echo "[Tier 02] Removing debug overhead..."

# --- KGDB 内核调试器 (安全隐患) ---
disable_opt CONFIG_KGDB
disable_opt CONFIG_KGDB_HONOUR_BLOCKLIST
disable_opt CONFIG_KGDB_SERIAL_CONSOLE
disable_opt CONFIG_KGDB_TESTS
disable_opt CONFIG_KGDB_LOW_LEVEL_TRAP

# --- DEBUG_INFO (编译调试符号，省数百MB + 大幅缩短编译时间) ---
disable_opt CONFIG_DEBUG_INFO
disable_opt CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
disable_opt CONFIG_DEBUG_INFO_COMPRESSED_NONE

# --- 内存调试 ---
disable_opt CONFIG_PAGE_OWNER
disable_opt CONFIG_PAGE_EXTENSION
disable_opt CONFIG_PAGE_POISONING
disable_opt CONFIG_DEBUG_VM
disable_opt CONFIG_DEBUG_VM_IRQSOFF
disable_opt CONFIG_DEBUG_SHIRQ
disable_opt CONFIG_DEBUG_DEVRES
disable_opt CONFIG_DEBUG_RODATA_TEST
disable_opt CONFIG_GENERIC_PTDUMP
disable_opt CONFIG_PTDUMP_CORE

# --- 调度器调试 ---
disable_opt CONFIG_SCHED_DEBUG
disable_opt CONFIG_SCHEDSTATS
disable_opt CONFIG_DEBUG_PREEMPT

# --- 启动调试 ---
disable_opt CONFIG_DEBUG_BOOT_PARAMS
disable_opt CONFIG_BOOT_PRINTK_DELAY

# --- debugfs 权限加固 (不删除 debugfs，改为默认不挂载) ---
switch_opt CONFIG_DEBUG_FS_ALLOW_ALL CONFIG_DEBUG_FS_DISALLOW_MOUNT

# --- 杂项调试 ---
disable_opt CONFIG_CRYPTO_STATS
disable_opt CONFIG_L2TP_DEBUGFS

count_after=$(grep -c '=y\|=m' "$CONFIG" || true)
echo "[Tier 02] Done. $((count_before - count_after)) options disabled."
echo "          Next: cd /usr/src/linux && make olddefconfig && make -j\$(nproc)"
