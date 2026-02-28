#!/usr/bin/env bash
# =============================================================================
# Tier 07 - Crypto 精简
#
# 针对 EPYC_7773x_supermicro_h12_ssl，7003 config crypto 本就精简。
# 实际需处理的项:
#   CRYPTO_DES=y              (不安全，已废弃，CRYPTO_LIB_DES 级联消失)
#   CRYPTO_ARC4=m             (RC4，不安全，CRYPTO_LIB_ARC4 级联消失)
#   CRYPTO_ECHAINIV=y         (AEAD IV 生成，仅 IPsec 需要，此平台不用)
#   CRYPTO_USER_API_ENABLE_OBSOLETE=y (通过用户 API 暴露废弃算法)
#
# 保留 (7003 config 已有):
#   AES + AES_NI_INTEL (AES-NI 指令在 AMD 上同样可用)
#   SHA1/256/512/3, HMAC, BLAKE2B, CMAC
#   GCM, CCM, CBC, CTR, ECB, AUTHENC, SEQIV
#   GHASH + GHASH_CLMUL_NI_INTEL (CLMUL 在 AMD 上同样可用)
#   SHA*_SSSE3 (SSSE3/SHA-NI 在 AMD 上同样可用)
#   RSA, ECDH, ECC, DH
#   CRC32/CRC32C, XXHASH
#   DEFLATE, LZO, LZ4, ZSTD
#   DRBG_HMAC, JITTERENTROPY
#   USER_API (HASH/SKCIPHER/RNG/AEAD)
#
# 注: 7003 config 无 BLOWFISH / CAMELLIA / SERPENT / TWOFISH / MD4 /
#     CAST5 / CAST6 / DEV_CCP / DEV_QAT 等，无需处理。
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/00-common.sh"

echo "[Tier 07] Stripping exotic/insecure crypto..."

# --- 不安全的对称加密 ---
disable_opt CONFIG_CRYPTO_DES        # CRYPTO_LIB_DES 级联消失
disable_opt CONFIG_CRYPTO_ARC4       # RC4，CRYPTO_LIB_ARC4 级联消失

# --- 仅 IPsec 需要的构造 (此平台不用 IPsec) ---
disable_opt CONFIG_CRYPTO_ECHAINIV   # Encrypted Chain IV Generator

# --- 通过用户 API 暴露废弃算法 ---
disable_opt CONFIG_CRYPTO_USER_API_ENABLE_OBSOLETE

count_after=$(grep -c '=y\|=m' "$CONFIG" || true)
echo "[Tier 07] Done. $((count_before - count_after)) options disabled."
echo "          Next: cd /usr/src/linux && make olddefconfig && make -j\$(nproc)"
echo "          IMPORTANT: 应用后务必测试 SSH 登录 + HTTPS 连接是否正常!"
