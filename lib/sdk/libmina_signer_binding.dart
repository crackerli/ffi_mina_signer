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

typedef native_derive_public_key = Void Function(Pointer<Uint8> sk, Pointer<Uint8> x, Pointer<Uint8> isOdd);
typedef NativeDerivePublicKey = void Function(Pointer<Uint8> sk, Pointer<Uint8> x, Pointer<Uint8> isOdd);
final NativeDerivePublicKey publicKeyFunc = libMinaSigner
    .lookup<NativeFunction<native_derive_public_key>>('native_derive_public_key_non_montgomery')
    .asFunction<NativeDerivePublicKey>();

// typedef native_derive_public_key_non_montgomery = Void Function(Pointer<Uint8> sk, Pointer<Uint8> x, Pointer<Uint8> isOdd);
// typedef NativeDerivePublicKeyNonMontgomery = void Function(Pointer<Uint8> sk, Pointer<Uint8> x, Pointer<Uint8> isOdd);
// final NativeDerivePublicKeyNonMontgomery publicKeyFuncNonMontgomery = libMinaSigner
//     .lookup<NativeFunction<native_derive_public_key_non_montgomery>>('native_derive_public_key_non_montgomery')
//     .asFunction<NativeDerivePublicKeyNonMontgomery>();

typedef sign_user_command_func = Void Function(
    Pointer<Uint8> sk,
    Pointer<Uint8> memo,
    Pointer<Uint8> feePayerAddress,
    Pointer<Uint8> senderAddress,
    Pointer<Uint8> receiverAddress,
    Pointer<Uint8> fee,  // uint64_t
    Pointer<Uint8> feeToken, // uint64_t
    Uint32 nonce,
    Uint32 validUntil,
    Pointer<Uint8> tokenId, // uint64_t
    Pointer<Uint8> amount, // uint64_t
    Uint8 tokenLocked,
    Uint8 txType,
    Pointer<Uint8> field,
    Pointer<Uint8> fieldLength,
    Pointer<Uint8> scalar,
    Pointer<Uint8> scalarLength,
    Uint8 networkId
    );

typedef SignUserCommand = void Function(
    Pointer<Uint8> sk,
    Pointer<Uint8> memo,
    Pointer<Uint8> feePayerAddress,
    Pointer<Uint8> senderAddress,
    Pointer<Uint8> receiverAddress,
    Pointer<Uint8> fee, // uint64_t
    Pointer<Uint8> feeToken, // uint64_t
    int nonce,
    int validUntil,
    Pointer<Uint8> tokenId, // uint64_t
    Pointer<Uint8> amount,  // uint64_t
    int tokenLocked,
    int txType,
    Pointer<Uint8> field,
    Pointer<Uint8> fieldLength,
    Pointer<Uint8> scalar,
    Pointer<Uint8> scalarLength,
    int networkId
    );
final SignUserCommand signUserCommandFunc = libMinaSigner
    .lookup<NativeFunction<sign_user_command_func>>('native_sign_user_command_non_montgomery')
    .asFunction<SignUserCommand>();