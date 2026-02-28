#!/usr/bin/env bash
# 公共函数，被各 tier 脚本 source

set -euo pipefail

CONFIG="${1:?Usage: $0 <path-to-.config>}"

[ -f "$CONFIG" ] || { echo "Error: $CONFIG not found"; exit 1; }

# macOS sed 需要 -i ''，GNU sed 需要 -i
if sed --version 2>/dev/null | grep -q GNU; then
    SED_INPLACE=(sed -i)
else
    SED_INPLACE=(sed -i '')
fi

# 将 CONFIG_XXX=y 或 CONFIG_XXX=m 改为 # CONFIG_XXX is not set
disable_opt() {
    local opt="$1"
    "${SED_INPLACE[@]}" -E "s/^${opt}=[ym]$/# ${opt} is not set/" "$CONFIG"
}

# 将 CONFIG_XXX=y 改为 CONFIG_YYY=y (用于互斥选项切换)
switch_opt() {
    local old="$1" new="$2"
    "${SED_INPLACE[@]}" "s/^${old}=y$/# ${old} is not set/" "$CONFIG"
    # 如果 new 选项已存在(被注释), 取消注释; 否则追加
    if grep -q "^# ${new} is not set" "$CONFIG"; then
        "${SED_INPLACE[@]}" "s/^# ${new} is not set$/${new}=y/" "$CONFIG"
    else
        echo "${new}=y" >> "$CONFIG"
    fi
}

count_before=$(grep -c '=y\|=m' "$CONFIG" || true)
