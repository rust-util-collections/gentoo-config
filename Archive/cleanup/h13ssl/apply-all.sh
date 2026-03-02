#!/usr/bin/env bash
# =============================================================================
# Apply all 8 tiers (maximum cleanup + Podman enablement)
#
# Usage: ./apply-all.sh <path-to-.config>
#
# Recommendation: Applying tier by tier is safer. Only use this script
# once you are confident that each individual tier works properly.
# =============================================================================

set -euo pipefail

CONFIG="${1:?Usage: $0 <path-to-.config>}"

[ -f "$CONFIG" ] || { echo "Error: $CONFIG not found"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

count_before=$(grep -c '=y\|=m' "$CONFIG" || true)

for tier in 01 02 03 04 05 06 07 08; do
    script="$SCRIPT_DIR/${tier}-*.sh"
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
echo "  make olddefconfig     # Clean up cascaded dependencies"
echo "  make -j\$(nproc)       # Compile"
echo "  # Install, reboot, and test SSH/nftables/Podman functionality"
