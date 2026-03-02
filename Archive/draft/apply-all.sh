#!/usr/bin/env bash
# =============================================================================
# 一键应用全部 7 个 tier (最大精简版)
#
# Usage: ./apply-all.sh <path-to-.config>
#
# 建议: 逐 tier 应用更安全。此脚本仅在你确认每个 tier 都没问题后使用。
# =============================================================================

set -euo pipefail

CONFIG="${1:?Usage: $0 <path-to-.config>}"

[ -f "$CONFIG" ] || { echo "Error: $CONFIG not found"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

count_before=$(grep -c '=y\|=m' "$CONFIG" || true)

for tier in 01 02 03 04 05 06 07; do
    script="$SCRIPT_DIR/${tier}-remove-*.sh"
    # shellcheck disable=SC2086
    bash $script "$CONFIG"
done

count_after=$(grep -c '=y\|=m' "$CONFIG" || true)
echo ""
echo "========================================="
echo " All tiers applied."
echo " Before: $count_before enabled options"
echo " After:  $count_after enabled options"
echo " Removed: $((count_before - count_after))"
echo "========================================="
echo ""
echo "Next steps:"
echo "  cd /usr/src/linux"
echo "  make olddefconfig     # 清理级联依赖"
echo "  make -j\$(nproc)       # 编译"
echo "  # 安装、重启、测试 SSH/nftables/基础功能"
