#!/usr/bin/env bash
# =============================================================================
# Tier 07 - Crypto 精简 (最激进)
#
# 删除异域/过时密码算法、非本平台硬件加密驱动
# 应用后务必测试 SSH 登录和 TLS 连接是否正常!
#
# 保留: AES(+AES-NI), SHA1/256/512/3, HMAC, BLAKE2B, CMAC
#       GCM, CCM, XTS, CBC, CTR, ECB, LRW, SEQIV, AUTHENC
#       RSA, ECDSA, ECDH, DH, ECC
#       CRC32C, CRCT10DIF, CRC64_ROCKSOFT, XXHASH
#       CHACHA20, POLY1305, CHACHA20POLY1305
#       DEFLATE, LZO, ZSTD
#       DRBG_HMAC, JITTERENTROPY
#       USER_API (HASH/SKCIPHER/RNG/AEAD)
#       DEV_CCP, DEV_SP_PSP (AMD 本平台硬件)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/00-common.sh"

echo "[Tier 07] Stripping exotic crypto..."

# --- 过时分组密码 ---
disable_opt CONFIG_CRYPTO_BLOWFISH
disable_opt CONFIG_CRYPTO_BLOWFISH_COMMON
disable_opt CONFIG_CRYPTO_BLOWFISH_X86_64
disable_opt CONFIG_CRYPTO_DES
disable_opt CONFIG_CRYPTO_DES3_EDE_X86_64
disable_opt CONFIG_CRYPTO_FCRYPT
disable_opt CONFIG_CRYPTO_CAST_COMMON
disable_opt CONFIG_CRYPTO_CAST5
disable_opt CONFIG_CRYPTO_CAST6
disable_opt CONFIG_CRYPTO_CAST5_AVX_X86_64
disable_opt CONFIG_CRYPTO_CAST6_AVX_X86_64
disable_opt CONFIG_CRYPTO_CAMELLIA
disable_opt CONFIG_CRYPTO_CAMELLIA_X86_64
disable_opt CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64
disable_opt CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64
disable_opt CONFIG_CRYPTO_SERPENT
disable_opt CONFIG_CRYPTO_SERPENT_SSE2_X86_64
disable_opt CONFIG_CRYPTO_SERPENT_AVX_X86_64
disable_opt CONFIG_CRYPTO_SERPENT_AVX2_X86_64
disable_opt CONFIG_CRYPTO_TWOFISH
disable_opt CONFIG_CRYPTO_TWOFISH_COMMON
disable_opt CONFIG_CRYPTO_TWOFISH_X86_64
disable_opt CONFIG_CRYPTO_TWOFISH_X86_64_3WAY
disable_opt CONFIG_CRYPTO_TWOFISH_AVX_X86_64

# --- 过时/异域哈希 ---
disable_opt CONFIG_CRYPTO_MD4
disable_opt CONFIG_CRYPTO_RMD160
disable_opt CONFIG_CRYPTO_WP512
disable_opt CONFIG_CRYPTO_STREEBOG
disable_opt CONFIG_CRYPTO_MICHAEL_MIC
disable_opt CONFIG_CRYPTO_VMAC
disable_opt CONFIG_CRYPTO_XCBC

# --- 异域非对称 ---
disable_opt CONFIG_CRYPTO_ECRDSA

# --- 不需要的模式/构造 ---
disable_opt CONFIG_CRYPTO_ADIANTUM
disable_opt CONFIG_CRYPTO_HCTR2
disable_opt CONFIG_CRYPTO_XCTR
disable_opt CONFIG_CRYPTO_NHPOLY1305
disable_opt CONFIG_CRYPTO_NHPOLY1305_SSE2
disable_opt CONFIG_CRYPTO_NHPOLY1305_AVX2
disable_opt CONFIG_CRYPTO_PCBC
disable_opt CONFIG_CRYPTO_KEYWRAP
disable_opt CONFIG_CRYPTO_AEGIS128
disable_opt CONFIG_CRYPTO_AEGIS128_AESNI_SSE2
disable_opt CONFIG_CRYPTO_ECHAINIV
disable_opt CONFIG_CRYPTO_ESSIV
disable_opt CONFIG_CRYPTO_AES_TI
disable_opt CONFIG_CRYPTO_ANSI_CPRNG
disable_opt CONFIG_CRYPTO_PCRYPT
disable_opt CONFIG_CRYPTO_OFB
disable_opt CONFIG_CRYPTO_CFB

# --- 不需要的压缩 ---
disable_opt CONFIG_CRYPTO_842

# --- 冗余 DRBG (HMAC 已足够) ---
disable_opt CONFIG_CRYPTO_DRBG_HASH
disable_opt CONFIG_CRYPTO_DRBG_CTR

# --- 不存在的硬件加密驱动 ---
disable_opt CONFIG_CRYPTO_DEV_PADLOCK
disable_opt CONFIG_CRYPTO_DEV_PADLOCK_AES
disable_opt CONFIG_CRYPTO_DEV_PADLOCK_SHA
disable_opt CONFIG_CRYPTO_DEV_ATMEL_I2C
disable_opt CONFIG_CRYPTO_DEV_ATMEL_ECC
disable_opt CONFIG_CRYPTO_DEV_ATMEL_SHA204A
disable_opt CONFIG_CRYPTO_DEV_VIRTIO
disable_opt CONFIG_CRYPTO_DEV_QAT
disable_opt CONFIG_CRYPTO_DEV_QAT_DH895xCC
disable_opt CONFIG_CRYPTO_DEV_QAT_C3XXX
disable_opt CONFIG_CRYPTO_DEV_QAT_C62X
disable_opt CONFIG_CRYPTO_DEV_QAT_4XXX
disable_opt CONFIG_CRYPTO_DEV_QAT_DH895xCCVF
disable_opt CONFIG_CRYPTO_DEV_QAT_C3XXXVF
disable_opt CONFIG_CRYPTO_DEV_QAT_C62XVF

# --- 杂项 ---
disable_opt CONFIG_CRYPTO_USER
disable_opt CONFIG_CRYPTO_POLYVAL_CLMUL_NI

count_after=$(grep -c '=y\|=m' "$CONFIG" || true)
echo "[Tier 07] Done. $((count_before - count_after)) options disabled."
echo "          Next: cd /usr/src/linux && make olddefconfig && make -j\$(nproc)"
echo "          IMPORTANT: 应用后务必测试 SSH 登录 + HTTPS 连接是否正常!"
