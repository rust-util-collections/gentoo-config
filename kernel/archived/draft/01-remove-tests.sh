#!/usr/bin/env bash
# =============================================================================
# Tier 01 - 删除纯测试代码 (最安全，零风险)
#
# KUnit 框架、torture 压力测试、启动时自测、其他测试模块
# 这些代码仅用于验证内核自身正确性，对运行无任何贡献
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/00-common.sh"

echo "[Tier 01] Removing test/selftest code..."

# --- KUnit 框架 (删主开关，make olddefconfig 自动清理子项) ---
disable_opt CONFIG_KUNIT
disable_opt CONFIG_RUNTIME_TESTING_MENU

# --- Torture / 压力测试 ---
disable_opt CONFIG_TORTURE_TEST
disable_opt CONFIG_LOCK_TORTURE_TEST
disable_opt CONFIG_RCU_TORTURE_TEST

# --- 启动时自测 (=y, 每次启动都跑!) ---
disable_opt CONFIG_X86_DECODER_SELFTEST
disable_opt CONFIG_ATOMIC64_SELFTEST
disable_opt CONFIG_TEST_KSTRTOX
disable_opt CONFIG_MEMCPY_SLOW_KUNIT_TEST

# --- 其他测试模块 ---
disable_opt CONFIG_TEST_SORT
disable_opt CONFIG_KPROBES_SANITY_TEST
disable_opt CONFIG_TEST_VMALLOC
disable_opt CONFIG_TEST_BPF
disable_opt CONFIG_RING_BUFFER_BENCHMARK
disable_opt CONFIG_EFI_TEST
disable_opt CONFIG_CRYPTO_TEST

count_after=$(grep -c '=y\|=m' "$CONFIG" || true)
echo "[Tier 01] Done. $((count_before - count_after)) options disabled."
echo "          Next: cd /usr/src/linux && make olddefconfig && make -j\$(nproc)"
