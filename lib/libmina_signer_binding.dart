import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

final libMinaSigner = _load();

DynamicLibrary _load() {
  // Load C library and functions
  final DynamicLibrary dynamicLibrary = Platform.isAndroid ?
    DynamicLibrary.open('libmina_signer.so') :
    DynamicLibrary.process();
  return dynamicLibrary;
}

// Struct of returned values from C library
// Generated key pairs from C library, need to manually allocate and release memory
class KeyPair extends Struct {
  Pointer<Utf8> privateKey;
  Pointer<Utf8> publicKey;
}

// C private key function
typedef private_key_func = Void Function(Pointer<Uint8> privateKeyBuffer);
typedef PrivateKey = void Function(Pointer<Uint8> privateKeyBuffer);

final PrivateKey nativeGenPrivateKey = libMinaSigner
    .lookup<NativeFunction<private_key_func>>('native_genPrivateKey')
    .asFunction();

// C public key function
// typedef public_key_func = Void Function(Pointer<Uint8> privateKey, Pointer<Uint8> publicKey);
// typedef PublicKey = void Function(Pointer<Uint8> privateKey, Pointer<Uint8> publicKey);
//
// final PublicKey nativeGenPublicKey = libMinaSigner
//     .lookup<NativeFunction<public_key_func>>('native_genPublicKey')
//     .asFunction();

// C sign message function
typedef sign_message_func = Void Function(Pointer<Uint8> message, Uint32 messageLen, Pointer<Uint8> privateKey, Pointer<Uint8> signature);
typedef SignMessage = void Function(Pointer<Uint8> message, int messageLen, Pointer<Uint8> privateKey, Pointer<Uint8> signature);

final SignMessage nativeSignMessage = libMinaSigner
    .lookup<NativeFunction<sign_message_func>>('native_signMessage')
    .asFunction();

// C verify signature function
typedef verify_signature_func = Int32 Function(Pointer<Uint8> signature, Pointer<Uint8> message, Uint32 messageLen, Pointer<Uint8> privateKey);
typedef VerifySignature = int Function(Pointer<Uint8> signature, Pointer<Uint8> message, int messageLen, Pointer<Uint8> privateKey);

final VerifySignature nativeVerifySignature = libMinaSigner
    .lookup<NativeFunction<verify_signature_func>>('native_verifySignature')
    .asFunction();

// C verify signature function
typedef sign_delegation_func = Void Function();
typedef SignDelegation = void Function();

final SignDelegation nativeSignDelegation = libMinaSigner
    .lookup<NativeFunction<sign_delegation_func>>('native_signDelegation')
    .asFunction();

typedef native_derive_publickey = Void Function(Pointer<Uint8> sk, Pointer<Uint8> x, Pointer<Uint8> isOdd);
typedef NativeDerivePublicKey = void Function(Pointer<Uint8> sk, Pointer<Uint8> x, Pointer<Uint8> isOdd);
final NativeDerivePublicKey pubkeyFunc = libMinaSigner
    .lookup<NativeFunction<native_derive_publickey>>('native_derive_public_key')
    .asFunction<NativeDerivePublicKey>();

// char *memo,
// char *fee_payer_address,
// char *sender_address;
// char *receiver_address;
// Currency fee,
//     TokenId fee_token,
// Nonce nonce,
//     GlobalSlot valid_until,
// Tag tag,
//     TokenId token_id,
// Currency amount,
//     bool token_locked,
// uint8_t transaction_type, // 0 for transaction, 1 for delegation
//     char *out_field,
// char *out_scalar

// C publickey function - void dart_publickey(unsigned char *sk, unsigned char *pk);
typedef sign_user_command_func = Void Function(
    Pointer<Uint8> memo,
    Pointer<Uint8> feePayerAddress,
    Pointer<Uint8> senderAddress,
    Pointer<Uint8> receiverAddress,
    Uint64 fee,
    Uint64 feeToken,
    Uint32 nonce,
    Uint32 validUntil,
    Uint64 tokenId,
    Uint64 amount,
    Uint8 tokenLocked,
    Uint8 txType,
    Pointer<Uint8> scalar,
    Pointer<Uint8> field
    );

typedef SignUserCommand = void Function(
    Pointer<Uint8> memo,
    Pointer<Uint8> feePayerAddress,
    Pointer<Uint8> senderAddress,
    Pointer<Uint8> receiverAddress,
    int fee,
    int feeToken,
    int nonce,
    int validUntil,
    int tokenId,
    int amount,
    int tokenLocked,
    int txType,
    Pointer<Uint8> scalar,
    Pointer<Uint8> field
    );
final SignUserCommand signUserCommandFunc = libMinaSigner
    .lookup<NativeFunction<sign_user_command_func>>('native_sign_user_command')
    .asFunction<SignUserCommand>();