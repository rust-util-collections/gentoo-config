#!/usr/bin/env bash
# Common functions sourced by each tier script

set -euo pipefail

CONFIG="${1:?Usage: $0 <path-to-.config>}"

[ -f "$CONFIG" ] || { echo "Error: $CONFIG not found"; exit 1; }

# macOS sed requires -i '' while GNU sed requires -i
if sed --version 2>/dev/null | grep -q GNU; then
    SED_INPLACE=(sed -i)
else
    SED_INPLACE=(sed -i '')
fi

# Change CONFIG_XXX=y or CONFIG_XXX=m to # CONFIG_XXX is not set
disable_opt() {
    local opt="$1"
    "${SED_INPLACE[@]}" -E "s/^${opt}=[ym]$/# ${opt} is not set/" "$CONFIG"
}

# Change CONFIG_XXX=y to CONFIG_YYY=y (for mutually exclusive option switching)
switch_opt() {
    local old="$1" new="$2"
    "${SED_INPLACE[@]}" "s/^${old}=y$/# ${old} is not set/" "$CONFIG"
    # If the new option already exists (commented out), uncomment it; otherwise append it
    if grep -q "^# ${new} is not set" "$CONFIG"; then
        "${SED_INPLACE[@]}" "s/^# ${new} is not set$/${new}=y/" "$CONFIG"
    else
        echo "${new}=y" >> "$CONFIG"
    fi
}

count_before=$(grep -c '=y\|=m' "$CONFIG" || true)
