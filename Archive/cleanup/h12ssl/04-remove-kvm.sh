#!/usr/bin/env bash
# =============================================================================
# Tier 04 - 删除 KVM / 虚拟化 (确认不用 KVM)
#
# 针对 EPYC_7773x_supermicro_h12_ssl 实际存在的项:
#   KVM=m, KVM_AMD=m, KVM_WERROR=y
#   KVM_ASYNC_PF / KVM_MMIO / KVM_VFIO / KVM_GENERIC_DIRTYLOG_READ_PROTECT /
#   KVM_XFER_TO_GUEST_WORK 会随 KVM 级联消失
#
# 注: 7003 config 无 KVM_AMD_SEV / KVM_SMM / VIRTIO，无需处理。
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/00-common.sh"

echo "[Tier 04] Removing KVM / virtualization..."

disable_opt CONFIG_KVM
disable_opt CONFIG_KVM_AMD
disable_opt CONFIG_KVM_WERROR
# KVM_ASYNC_PF / KVM_MMIO / KVM_VFIO / KVM_GENERIC_DIRTYLOG_READ_PROTECT /
# KVM_XFER_TO_GUEST_WORK 均依赖 KVM，make olddefconfig 自动清理

count_after=$(grep -c '=y\|=m' "$CONFIG" || true)
echo "[Tier 04] Done. $((count_before - count_after)) options disabled."
echo "          Next: cd /usr/src/linux && make olddefconfig && make -j\$(nproc)"
