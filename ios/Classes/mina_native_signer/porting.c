#include <stdio.h>
#include "pasta_fp.h"
#include "pasta_fq.h"
#include "crypto.h"
#include "libbase58.h"
#include "base10.h"
#include <android/log.h>

// Copy g_generator from crypto.c, this let the code merge from Izaak easy
// g_generator = (1 : 12418654782883325593414442427049395787963493412651469444558597405572177144507)
static const Affine AFFINE_ONE = {
    {
        0x34786d38fffffffd, 0x992c350be41914ad, 0xffffffffffffffff, 0x3fffffffffffffff
    },
    {
        0x2f474795455d409d, 0xb443b9b74b8255d9, 0x270c412f2c9a5d66, 0x8e00f71ba43dd6b
    }
};

void copy64_big_endian(uint8_t *dst, uint64_t w) {
  uint8_t *p = ( uint8_t * )dst;
  p[0] = (uint8_t)(w >>  0);
  p[1] = (uint8_t)(w >>  8);
  p[2] = (uint8_t)(w >> 16);
  p[3] = (uint8_t)(w >> 24);
  p[4] = (uint8_t)(w >> 32);
  p[5] = (uint8_t)(w >> 40);
  p[6] = (uint8_t)(w >> 48);
  p[7] = (uint8_t)(w >> 56);
}

static void print_uint64_t(uint64_t w) {
  __android_log_print(ANDROID_LOG_DEBUG, "MinaKeys", "field byte = %x", (uint8_t)(w >>  0));
  __android_log_print(ANDROID_LOG_DEBUG, "MinaKeys", "field byte = %x", (uint8_t)(w >>  8));
  __android_log_print(ANDROID_LOG_DEBUG, "MinaKeys", "field byte = %x", (uint8_t)(w >>  16));
  __android_log_print(ANDROID_LOG_DEBUG, "MinaKeys", "field byte = %x", (uint8_t)(w >>  24));
  __android_log_print(ANDROID_LOG_DEBUG, "MinaKeys", "field byte = %x", (uint8_t)(w >>  32));
  __android_log_print(ANDROID_LOG_DEBUG, "MinaKeys", "field byte = %x", (uint8_t)(w >>  40));
  __android_log_print(ANDROID_LOG_DEBUG, "MinaKeys", "field byte = %x", (uint8_t)(w >>  48));
  __android_log_print(ANDROID_LOG_DEBUG, "MinaKeys", "field byte = %x", (uint8_t)(w >>  56));
}

void native_derive_public_key(uint8_t *sk, uint8_t *x, uint8_t *isOdd) {
    uint64_t tmp[4];
    uint64_t tmp_sk[4];
    Affine pub_key;

    memset(tmp, 0, sizeof(tmp));
    memset(tmp_sk, 0, sizeof(tmp_sk));
    memset(&pub_key, 0, sizeof(pub_key));
    memcpy(tmp_sk, sk, 32);

    affine_scalar_mul(&pub_key, tmp_sk, &AFFINE_ONE);
    // 1. copy x coordinate
    fiat_pasta_fp_from_montgomery(tmp, pub_key.x);
    copy64_big_endian(x,      tmp[0]);
    copy64_big_endian(x + 8,  tmp[1]);
    copy64_big_endian(x + 16, tmp[2]);
    copy64_big_endian(x + 24, tmp[3]);
    print_uint64_t(tmp[3]);

    // 2. copy parity
    memset(tmp, 0, sizeof(tmp));
    fiat_pasta_fp_from_montgomery(tmp, pub_key.y);
    isOdd[0] = tmp[0] & 0x01;
}

static void read_public_key_compressed(Compressed* out, char* pubkeyBase58) {
  size_t pubkeyBytesLen = 40;
  unsigned char pubkeyBytes[40];
  b58tobin(pubkeyBytes, &pubkeyBytesLen, pubkeyBase58, 0);

  uint64_t x_coord_non_montgomery[4] = { 0, 0, 0, 0 };

  size_t offset = 3;
  for (size_t i = 0; i < 4; ++i) {
    const size_t BYTES_PER_LIMB = 8;
    // 8 bytes per limb
    for (size_t j = 0; j < BYTES_PER_LIMB; ++j) {
      size_t k = offset + BYTES_PER_LIMB * i + j;
      x_coord_non_montgomery[i] |= ( ((uint64_t) pubkeyBytes[k]) << (8 * j));
    }
  }

  fiat_pasta_fp_to_montgomery(out->x, x_coord_non_montgomery);
  out->is_odd = (bool) pubkeyBytes[offset + 32];
}

static void prepare_memo(uint8_t* out, char* s) {
  size_t len = strlen(s);
  out[0] = 1;
  out[1] = len; // length
  for (size_t i = 0; i < len; ++i) {
    out[2 + i] = s[i];
  }
  for (size_t i = 2 + len; i < MEMO_BYTES; ++i) {
    out[i] = 0;
  }
}

void native_sign_user_command(
    char *memo,
    char *fee_payer_address,
    char *sender_address,
    char *receiver_address,
    Currency fee,
    TokenId fee_token,
    Nonce nonce,
    GlobalSlot valid_until,
    TokenId token_id,
    Currency amount,
    bool token_locked,
    uint8_t transaction_type, // 0 for transaction, 1 for delegation
    char *out_field,
    char *out_scalar
) {
    Transaction txn;
Scalar priv_key = { 0xca14d6eed923f6e3, 0x61185a1b5e29e6b2, 0xe26d38de9c30753b, 0x3fdf0efb0a5714 };
    prepare_memo(txn.memo, memo);

    txn.fee = fee;
    txn.fee_token = fee_token;
    read_public_key_compressed(&txn.fee_payer_pk, fee_payer_address);
    txn.nonce = nonce;
    txn.valid_until = valid_until;

    if(0 == transaction_type) {
        txn.tag[0] = 0;
        txn.tag[1] = 0;
        txn.tag[2] = 0;
    } else {
        txn.tag[0] = 0;
        txn.tag[1] = 0;
        txn.tag[2] = 1;
    }

    read_public_key_compressed(&txn.source_pk, sender_address);
    read_public_key_compressed(&txn.receiver_pk, receiver_address);
    txn.token_id = token_id;
    txn.amount = amount;
    txn.token_locked = false;

    Keypair kp;
    scalar_copy(kp.priv, priv_key);
    generate_pubkey(&kp.pub, priv_key);
    fiat_pasta_fp_print(kp.pub.x);

    Signature sig;
    sign(&sig, &kp, &txn);

    char field_str[DIGITS] = { 0 };
    char scalar_str[DIGITS] = { 0 };
    uint64_t tmp[4];
    fiat_pasta_fp_from_montgomery(tmp, sig.rx);
    bigint_to_string(out_field, tmp);

    memset(tmp, 0, sizeof(tmp));
    fiat_pasta_fq_from_montgomery(tmp, sig.s);
    bigint_to_string(out_scalar, tmp);

    printf("{ publicKey: '%s',\n", fee_payer_address);
    __android_log_print(ANDROID_LOG_DEBUG, "CK1", "publicKey: '%s', \n", fee_payer_address);
    printf("  signature:\n");
    printf("   { field:\n");
    printf("      '%s',\n", out_field);
    __android_log_print(ANDROID_LOG_DEBUG, "CK1", "native field: '%s', \n", out_field);
    printf("     scalar:\n");
    printf("      '%s' },\n", out_scalar);
    printf("  payload:\n");
    printf("   { to: '%s',\n", receiver_address);
    printf("     from: '%s',\n", sender_address);
    printf("     fee: '%lu',\n", txn.fee);
    printf("     amount: '%lu',\n", txn.amount);
    printf("     nonce: '%u',\n", txn.nonce);
    printf("     memo: '%s',\n", txn.memo); // TODO: This should actually be b58 encoded
    printf("     validUntil: '%u' } }\n", txn.valid_until);

    printf("\npayment signature only:\n");

    char buf[DIGITS] = { 0 };

    fiat_pasta_fp_from_montgomery(tmp, sig.rx);
    bigint_to_string(buf, tmp);
    printf("field = %s\n", buf);
__android_log_print(ANDROID_LOG_DEBUG, "CK1", "field: '%s', \n", buf);
    for (size_t i = 0; i < DIGITS; ++i) { buf[i] = 0; }

    fiat_pasta_fq_from_montgomery(tmp, sig.s);
    bigint_to_string(buf, tmp);
    printf("scalar = %s\n", buf);
    __android_log_print(ANDROID_LOG_DEBUG, "CK1", "scalar: '%s', \n", buf);
}
