#include <stdio.h>
#include "pasta_fp.h"
#include "pasta_fq.h"
#include "crypto.h"
#include "libbase58.h"
#include "base10.h"
#ifdef ANDROID_LIB
#include <android/log.h>
#endif
#include "porting.h"

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
#ifdef ANDROID_LIB
  __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "field byte = %x", (uint8_t)(w >>  0));
  __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "field byte = %x", (uint8_t)(w >>  8));
  __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "field byte = %x", (uint8_t)(w >>  16));
  __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "field byte = %x", (uint8_t)(w >>  24));
  __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "field byte = %x", (uint8_t)(w >>  32));
  __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "field byte = %x", (uint8_t)(w >>  40));
  __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "field byte = %x", (uint8_t)(w >>  48));
  __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "field byte = %x", (uint8_t)(w >>  56));
#else
  printf("field byte = %x;", (uint8_t)(w >>  0));
  printf("field byte = %x;", (uint8_t)(w >>  8));
  printf("field byte = %x;", (uint8_t)(w >>  16));
  printf("field byte = %x;", (uint8_t)(w >>  24));
  printf("field byte = %x;", (uint8_t)(w >>  32));
  printf("field byte = %x;", (uint8_t)(w >>  40));
  printf("field byte = %x;", (uint8_t)(w >>  48));
  printf("field byte = %x;", (uint8_t)(w >>  56));
#endif
}

/*
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
*/
/*
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
*/

void native_derive_public_key_montgomery(uint8_t *sk, uint8_t *x, uint8_t *isOdd) {
    uint64_t tmp[4];
    Affine pub_key;

    memset(tmp, 0, sizeof(tmp));
    memset(&pub_key, 0, sizeof(pub_key));

    affine_scalar_mul(&pub_key, sk, &AFFINE_ONE);
    // 1. copy x coordinate
    fiat_pasta_fp_from_montgomery(tmp, pub_key.x);
    /*
    copy64_big_endian(x,      tmp[0]);
    copy64_big_endian(x + 8,  tmp[1]);
    copy64_big_endian(x + 16, tmp[2]);
    copy64_big_endian(x + 24, tmp[3]);
    */
    memcpy(x, (uint8_t*)tmp, sizeof(tmp));

    // 2. copy parity
    memset(tmp, 0, sizeof(tmp));
    fiat_pasta_fp_from_montgomery(tmp, pub_key.y);
    isOdd[0] = tmp[0] & 0x01;
}

// Secret key is not of montgomery curve
void native_derive_public_key_non_montgomery(uint8_t *sk, uint8_t *x, uint8_t *isOdd) {
    // Convert sk to montgomery first
    uint64_t tmp[4];
    memset(tmp, 0, sizeof(tmp));
    fiat_pasta_fq_to_montgomery(tmp, sk);
    native_derive_public_key_montgomery(tmp, x, isOdd);
}

// Secret key is not of montgomery curve
void native_sign_user_command_non_montgomery(
    uint8_t *sk,
    char *memo,
    char *fee_payer_address,
    char *sender_address,
    char *receiver_address,
    uint8_t *fee,
    uint8_t *fee_token,
    Nonce nonce,
    GlobalSlot valid_until,
    uint8_t *token_id,
    uint8_t *amount,
    bool token_locked,
    uint8_t transaction_type, // 0 for transaction, 1 for delegation
    char *out_field,
    uint8_t *field_length,
    char *out_scalar,
    uint8_t *scalar_length
) {
    // Convert sk to montgomery first
    uint64_t tmp[4];
    Currency amount64;
    Currency fee64;
    TokenId fee_token64;
    TokenId token_id64;

    memset(tmp, 0, sizeof(tmp));
    memset(&amount64, 0, sizeof(amount64));
    memset(&fee64, 0, sizeof(fee64));
    memset(&fee_token64, 0, sizeof(fee_token64));
    memset(&token_id64, 0, sizeof(token_id64));

    fiat_pasta_fq_to_montgomery(tmp, sk);
    memcpy(&amount64, amount, sizeof(amount));
    memcpy(&fee64, fee, sizeof(fee));
    memcpy(&fee_token64, fee_token, sizeof(fee_token));
    memcpy(&token_id64, token_id, sizeof(token_id));
    native_sign_user_command_montgomery(tmp, memo, fee_payer_address, sender_address,
      receiver_address, fee64, fee_token64, nonce, valid_until,
      token_id64, amount64, token_locked, transaction_type, out_field, field_length, out_scalar, scalar_length);
}

Scalar priv_key = { 0xca14d6eed923f6e3, 0x61185a1b5e29e6b2, 0xe26d38de9c30753b, 0x3fdf0efb0a5714 };

void native_sign_user_command_montgomery(
    uint8_t *sk,
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
    uint8_t *field_length,
    char *out_scalar,
    uint8_t *scalar_length
) {
    Transaction txn;

    prepare_memo(txn.memo, memo);
    #ifdef ANDROID_LIB
    __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "memo=%s", memo);
    __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "fee_payer_address=%s", fee_payer_address);
    __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "sender_address=%s", sender_address);
    __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "receiver_address=%s", receiver_address);
    __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "fee=%lu", fee);
    __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "fee_token=%lu", fee_token);
    __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "nonce=%lu", nonce);
    __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "valid_until=%lu", valid_until);
    __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "token_id=%lu", token_id);
    __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "amount=%lu", amount);
    __android_log_print(ANDROID_LOG_DEBUG, NATIVE_TAG, "token_locked=%d", token_locked);
    #else
    printf("memo=%s\n", memo);
    printf("memo=%s\n", memo);
    printf("fee_payer_address=%s\n", fee_payer_address);
    printf("sender_address=%s\n", sender_address);
    printf("receiver_address=%s\n", receiver_address);
    printf("fee=%lu\n", fee);
    printf("fee_token=%lu\n", fee_token);
    printf("nonce=%lu\n", nonce);
    printf("valid_until=%lu\n", valid_until);
    printf("token_id=%lu\n", token_id);
    printf("amount=%lu\n", amount);
    printf("token_locked=%d\n", token_locked);
    #endif

    txn.fee = fee;
    txn.fee_token = fee_token;
    read_public_key_compressed(&txn.fee_payer_pk, fee_payer_address);
    txn.nonce = nonce;
    txn.valid_until = valid_until;

    if(0 == transaction_type) {
        txn.tag[0] = 0;
        txn.tag[1] = 0;
        txn.tag[2] = 0;
        txn.amount = amount;
    } else {
        txn.tag[0] = 0;
        txn.tag[1] = 0;
        txn.tag[2] = 1;
        txn.amount = 0;
    }

    read_public_key_compressed(&txn.source_pk, sender_address);
    read_public_key_compressed(&txn.receiver_pk, receiver_address);
    txn.token_id = token_id;
    txn.token_locked = false;

    Keypair kp;
//    memcpy(sk, priv_key, sizeof(uint64_t) * 4);
    scalar_copy(kp.priv, sk);
    generate_pubkey(&kp.pub, sk);

    Compressed pub_compressed;
    compress(&pub_compressed, &kp.pub);

    Signature sig;
    sign(&sig, &kp, &txn, 0);

    char field_str[DIGITS] = { 0 };
    char scalar_str[DIGITS] = { 0 };
    uint64_t tmp[4];
    memset(tmp, 0, sizeof(tmp));

    fiat_pasta_fp_from_montgomery(tmp, sig.rx);
    bigint_to_string(out_field, tmp);
    field_length[0] = strlen(out_field);
    memset(tmp, 0, sizeof(tmp));
    fiat_pasta_fq_from_montgomery(tmp, sig.s);
    bigint_to_string(out_scalar, tmp);
    scalar_length[0] = strlen(out_scalar);
}
