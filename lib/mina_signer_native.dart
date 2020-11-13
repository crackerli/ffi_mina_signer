import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// Load C library and functions
final DynamicLibrary dynamicLibrary = Platform.isAndroid ?
  DynamicLibrary.open('libmina_signer.so') :
  DynamicLibrary.process();

// Struct of returned values from C library

// Generated key pairs from C library, need to manually allocate and release memory
class KeyPair extends Struct {
  Pointer<Utf8> privateKey;
  Pointer<Utf8> publicKey;
}

// C private key function
typedef private_key_func = Void Function(Pointer<Uint8> privateKeyBuffer);
typedef PrivateKey = void Function(Pointer<Uint8> privateKeyBuffer);

final PrivateKey nativeGenPrivateKey = dynamicLibrary
  .lookup<NativeFunction<private_key_func>>('native_genPrivateKey')
  .asFunction();

// C public key function
typedef public_key_func = Void Function(Pointer<Uint8> privateKey, Pointer<Uint8> publicKey);
typedef PublicKey = void Function(Pointer<Uint8> privateKey, Pointer<Uint8> publicKey);

final PublicKey nativeGenPublicKey = dynamicLibrary
  .lookup<NativeFunction<public_key_func>>('native_genPublicKey')
  .asFunction();

// C sign message function
typedef sign_message_func = Void Function(Pointer<Uint8> message, Uint32 messageLen, Pointer<Uint8> privateKey, Pointer<Uint8> signature);
typedef SignMessage = void Function(Pointer<Uint8> message, int messageLen, Pointer<Uint8> privateKey, Pointer<Uint8> signature);

final SignMessage nativeSignMessage = dynamicLibrary
  .lookup<NativeFunction<sign_message_func>>('native_signMessage')
  .asFunction();

// C verify signature function
typedef verify_signature_func = Int32 Function(Pointer<Uint8> signature, Pointer<Uint8> message, Uint32 messageLen, Pointer<Uint8> privateKey);
typedef VerifySignature = int Function(Pointer<Uint8> signature, Pointer<Uint8> message, int messageLen, Pointer<Uint8> privateKey);

final VerifySignature nativeVerifySignature = dynamicLibrary
  .lookup<NativeFunction<verify_signature_func>>('native_verifySignature')
  .asFunction();




