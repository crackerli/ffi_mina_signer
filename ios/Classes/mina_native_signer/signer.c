#include <stdio.h>
#include "pasta_fp.h"
#include "pasta_fq.h"
#include "crypto.h"
#include "libbase58.h"
#include "base10.h"
#include <android/log.h>

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
