#!/usr/bin/env bash
# =============================================================================
# Tier 04 - 删除 KVM / 虚拟化 (确认不用 KVM)
#
# KVM, KVM_AMD, SEV, VIRTIO
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/00-common.sh"

echo "[Tier 04] Removing KVM / virtualization..."

disable_opt CONFIG_KVM
disable_opt CONFIG_KVM_WERROR
disable_opt CONFIG_KVM_AMD
disable_opt CONFIG_KVM_AMD_SEV
disable_opt CONFIG_KVM_SMM
disable_opt CONFIG_VIRTIO
disable_opt CONFIG_VIRTIO_NET

count_after=$(grep -c '=y\|=m' "$CONFIG" || true)
echo "[Tier 04] Done. $((count_before - count_after)) options disabled."
echo "          Next: cd /usr/src/linux && make olddefconfig && make -j\$(nproc)"
