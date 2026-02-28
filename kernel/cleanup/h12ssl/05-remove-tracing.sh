#!/usr/bin/env bash
# =============================================================================
# Tier 05 - 删除 Tracing / Profiling (确认不用 perf/bpftrace)
#
# 针对 EPYC_7773x_supermicro_h12_ssl 实际存在的项:
#   FTRACE=y        (删主开关，级联消失: DYNAMIC_FTRACE / FUNCTION_TRACER /
#                    FUNCTION_GRAPH_TRACER / CONTEXT_SWITCH_TRACER /
#                    FTRACE_MCOUNT_RECORD / FTRACE_MCOUNT_USE_CC 等)
#   PROFILING=y
#   KPROBES=y       (级联消失: KPROBES_ON_FTRACE)
#   UPROBES=y
#   BPF_EVENTS=y
#   PERF_EVENTS_INTEL_RAPL=m  (Intel 专用计数器，AMD 平台无此硬件)
#
# 注: 7003 config 无 LATENCYTOP / BLK_DEV_IO_TRACE / FTRACE_SYSCALLS，
#     无需处理。
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/00-common.sh"

echo "[Tier 05] Removing tracing / profiling..."

# --- Ftrace 主开关 (删后大部分子项级联消失) ---
disable_opt CONFIG_FTRACE

# --- 性能分析基础设施 ---
disable_opt CONFIG_PROFILING

# --- 探针 ---
disable_opt CONFIG_KPROBES
disable_opt CONFIG_UPROBES

# --- BPF/uprobe 事件 ---
disable_opt CONFIG_BPF_EVENTS

# --- Intel 专用计数器 (AMD 平台无此硬件) ---
disable_opt CONFIG_PERF_EVENTS_INTEL_RAPL

count_after=$(grep -c '=y\|=m' "$CONFIG" || true)
echo "[Tier 05] Done. $((count_before - count_after)) options disabled."
echo "          Next: cd /usr/src/linux && make olddefconfig && make -j\$(nproc)"
