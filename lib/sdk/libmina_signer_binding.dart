import 'dart:ffi';
import 'dart:io';

final libMinaSigner = _load();

DynamicLibrary _load() {
  // Load C library and functions
  final DynamicLibrary dynamicLibrary = Platform.isAndroid ?
    DynamicLibrary.open('libmina_signer.so') :
    DynamicLibrary.process();
  return dynamicLibrary;
}

typedef native_derive_public_key = Void Function(Pointer<Uint8> sk, Pointer<Uint8> x, Pointer<Uint8> isOdd);
typedef NativeDerivePublicKey = void Function(Pointer<Uint8> sk, Pointer<Uint8> x, Pointer<Uint8> isOdd);
final NativeDerivePublicKey publicKeyFunc = libMinaSigner
    .lookup<NativeFunction<native_derive_public_key>>('native_derive_public_key_non_montgomery')
    .asFunction<NativeDerivePublicKey>();

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