#!/usr/bin/env bash
# =============================================================================
# Tier 03 - 删除不存在的硬件 / 过时协议 / 无用驱动 (安全)
#
# FireWire, 并口, ATM, Media, 笔记本 ACPI, Legacy 驱动,
# 无用 DRM/FB 驱动, 无用文件系统
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/00-common.sh"

echo "[Tier 03] Removing dead hardware / legacy drivers..."

# --- FireWire (IEEE 1394, 服务器无此硬件) ---
disable_opt CONFIG_FIREWIRE
disable_opt CONFIG_FIREWIRE_OHCI
disable_opt CONFIG_FIREWIRE_SBP2
disable_opt CONFIG_FIREWIRE_NET
disable_opt CONFIG_FIREWIRE_NOSY

# --- 并口 (服务器无此硬件) ---
disable_opt CONFIG_PARPORT
disable_opt CONFIG_PARPORT_PC
disable_opt CONFIG_PARPORT_SERIAL
disable_opt CONFIG_PARPORT_1284

# --- ATM (已死网络技术) ---
disable_opt CONFIG_ATM
disable_opt CONFIG_ATM_CLIP
disable_opt CONFIG_ATM_LANE
disable_opt CONFIG_ATM_BR2684
disable_opt CONFIG_ATM_DRIVERS
disable_opt CONFIG_ATM_TCP
disable_opt CONFIG_ATM_ENI
disable_opt CONFIG_ATM_NICSTAR
disable_opt CONFIG_ATM_HE
disable_opt CONFIG_ATM_SOLOS

# --- Media 子系统 (无摄像头/采集卡) ---
disable_opt CONFIG_MEDIA_SUPPORT

# --- 不需要的 DRM 驱动 (保留 AST + SimpleDRM) ---
disable_opt CONFIG_DRM_I2C_CH7006
disable_opt CONFIG_DRM_I2C_SIL164
disable_opt CONFIG_DRM_ANALOGIX_ANX78XX
disable_opt CONFIG_DRM_ANALOGIX_DP
disable_opt CONFIG_DRM_PANEL_ORIENTATION_QUIRKS
disable_opt CONFIG_DRM_LOAD_EDID_FIRMWARE

# --- 不需要的 FB 选项 ---
disable_opt CONFIG_FRAMEBUFFER_CONSOLE_ROTATION
disable_opt CONFIG_FB_VESA
disable_opt CONFIG_FB_TILEBLITTING

# --- ACPI 笔记本/桌面功能 ---
disable_opt CONFIG_ACPI_DOCK
disable_opt CONFIG_ACPI_DPTF
disable_opt CONFIG_ACPI_BGRT
disable_opt CONFIG_ACPI_BUTTON

# --- Legacy 驱动 ---
disable_opt CONFIG_X86_PMEM_LEGACY_DEVICE
disable_opt CONFIG_X86_PMEM_LEGACY
disable_opt CONFIG_EEPROM_LEGACY
disable_opt CONFIG_EEPROM_MAX6875
disable_opt CONFIG_EEPROM_93CX6
disable_opt CONFIG_EDAC_LEGACY_SYSFS

# --- 不需要的文件系统 ---
disable_opt CONFIG_F2FS_FS
disable_opt CONFIG_UDF_FS
disable_opt CONFIG_MSDOS_FS
disable_opt CONFIG_ROMFS_FS
disable_opt CONFIG_ISO9660_FS

# --- 杂项 ---
disable_opt CONFIG_BLK_DEV_DRBD
disable_opt CONFIG_SERIO_SERPORT
disable_opt CONFIG_BACKLIGHT_CLASS_DEVICE

count_after=$(grep -c '=y\|=m' "$CONFIG" || true)
echo "[Tier 03] Done. $((count_before - count_after)) options disabled."
echo "          Next: cd /usr/src/linux && make olddefconfig && make -j\$(nproc)"
