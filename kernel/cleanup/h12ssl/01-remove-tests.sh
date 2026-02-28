#!/usr/bin/env bash
# =============================================================================
# Tier 01 - 删除纯测试代码 (最安全，零风险)
#
# 经分析：EPYC_7773x_supermicro_h12_ssl 中无任何 KUnit / torture /
# selftest 选项，本 tier 对该配置无实际改动。
#
# 保留此脚本以保持 tier 编号一致性，方便将来 config 更新后复用。
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/00-common.sh"

echo "[Tier 01] Checking for test/selftest code..."

# 7003 config 中均不存在，调用后为幂等无害操作
disable_opt CONFIG_KUNIT
disable_opt CONFIG_RUNTIME_TESTING_MENU
disable_opt CONFIG_TORTURE_TEST
disable_opt CONFIG_LOCK_TORTURE_TEST
disable_opt CONFIG_RCU_TORTURE_TEST
disable_opt CONFIG_EFI_TEST
disable_opt CONFIG_CRYPTO_TEST
disable_opt CONFIG_TEST_BPF
disable_opt CONFIG_RING_BUFFER_BENCHMARK

count_after=$(grep -c '=y\|=m' "$CONFIG" || true)
echo "[Tier 01] Done. $((count_before - count_after)) options disabled."
echo "          (7003 config 中原本就无测试选项，属正常)"
