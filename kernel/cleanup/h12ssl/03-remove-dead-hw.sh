#!/usr/bin/env bash
# =============================================================================
# Tier 03 - 删除不存在的硬件 / 过时协议 / 无用驱动 (安全)
#
# 针对 EPYC_7773x_supermicro_h12_ssl 实际存在的项:
#   ACPI_BUTTON=y   (服务器无 lid/power button)
#   PARPORT=m       (服务器无并口)
#   MEDIA_SUPPORT=m (无摄像头/采集卡)
#   F2FS_FS=y       (Flash 文件系统，服务器磁盘不需要)
#   ISO9660_FS=m    (CD-ROM 文件系统，无光驱)
#   UDF_FS=m        (光盘/移动存储格式，不需要)
#   IIO=m           (工业传感器 I/O 子系统，服务器无此硬件)
#   AMD_SFH_HID=m   (AMD Smart Fusion 传感器枢纽，笔记本专用)
#   IP_PNP=y        (内核级 DHCP/BOOTP/RARP，由 userspace dhcpcd 代劳)
#
# 注: 7003 config 无 FIREWIRE / ATM / ACPI_DOCK / ACPI_BGRT / ACPI_DPTF /
#     X86_PMEM_LEGACY / EEPROM_LEGACY / MSDOS_FS / ROMFS_FS，无需处理。
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/00-common.sh"

echo "[Tier 03] Removing dead hardware / legacy drivers..."

# --- ACPI 笔记本/桌面功能 ---
disable_opt CONFIG_ACPI_BUTTON

# --- 并口 ---
disable_opt CONFIG_PARPORT

# --- Media 子系统 (无摄像头/采集卡) ---
disable_opt CONFIG_MEDIA_SUPPORT
# MEDIA_CONTROLLER / MEDIA_PLATFORM_SUPPORT / MEDIA_SUPPORT_FILTER 会级联消失

# --- 不需要的文件系统 ---
disable_opt CONFIG_F2FS_FS
# F2FS_IOSTAT / F2FS_STAT_FS 会级联消失
disable_opt CONFIG_ISO9660_FS
disable_opt CONFIG_UDF_FS

# --- 工业传感器 I/O (服务器无此硬件) ---
disable_opt CONFIG_IIO

# --- AMD 笔记本传感器枢纽 (服务器不存在) ---
disable_opt CONFIG_AMD_SFH_HID

# --- 内核级网络自动配置 (由 userspace 处理) ---
disable_opt CONFIG_IP_PNP
# IP_PNP_BOOTP / IP_PNP_DHCP / IP_PNP_RARP 会级联消失

count_after=$(grep -c '=y\|=m' "$CONFIG" || true)
echo "[Tier 03] Done. $((count_before - count_after)) options disabled."
echo "          Next: cd /usr/src/linux && make olddefconfig && make -j\$(nproc)"
