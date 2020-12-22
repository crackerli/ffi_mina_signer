//
// Created by crackerli on 2020/12/22.
//

#ifndef FFI_MINA_SIGNER_PORTING_H
#define FFI_MINA_SIGNER_PORTING_H

void native_derive_public_key_montgomery(uint8_t *sk, uint8_t *x, uint8_t *isOdd);
void native_derive_public_key_non_mongomery(uint8_t *sk, uint8_t *x, uint8_t *isOdd);
void native_sign_user_command(
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
    char *out_scalar
);

#endif //FFI_MINA_SIGNER_PORTING_H
