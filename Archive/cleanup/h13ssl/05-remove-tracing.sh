#!/usr/bin/env bash
# =============================================================================
# Tier 05 - 删除 Tracing / Profiling (确认不用 perf/bpftrace)
#
# FTRACE, KPROBES, UPROBES, PROFILING, Runtime Verification
# 删后丧失动态追踪能力，但减少代码体积
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/00-common.sh"

echo "[Tier 05] Removing tracing / profiling..."

# --- Ftrace 主开关 (删后大部分子项级联消失) ---
disable_opt CONFIG_FTRACE
disable_opt CONFIG_BOOTTIME_TRACING

# --- 性能分析基础设施 ---
disable_opt CONFIG_PROFILING

# --- 探针 ---
disable_opt CONFIG_KPROBES
disable_opt CONFIG_UPROBES

# --- 块 I/O 追踪 ---
disable_opt CONFIG_BLK_DEV_IO_TRACE

# --- BPF/uprobe 事件 ---
disable_opt CONFIG_BPF_EVENTS
disable_opt CONFIG_UPROBE_EVENTS

# --- 延迟分析 ---
disable_opt CONFIG_LATENCYTOP

# --- Runtime Verification ---
disable_opt CONFIG_RV

# --- 不需要的 early printk 变体 (保留基础 EARLY_PRINTK) ---
disable_opt CONFIG_EARLY_PRINTK_USB
disable_opt CONFIG_EARLY_PRINTK_DBGP
disable_opt CONFIG_EARLY_PRINTK_USB_XDBC

# --- Intel 专用 (此平台是 AMD) ---
disable_opt CONFIG_PERF_EVENTS_INTEL_RAPL

count_after=$(grep -c '=y\|=m' "$CONFIG" || true)
echo "[Tier 05] Done. $((count_before - count_after)) options disabled."
echo "          Next: cd /usr/src/linux && make olddefconfig && make -j\$(nproc)"
