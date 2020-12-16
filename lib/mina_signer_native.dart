import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:base58check/base58.dart';
import 'package:convert/convert.dart';
import 'package:ffi_mina_signer/util/mina_helper.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/digests/sha256.dart';

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

// C verify signature function
typedef sign_delegation_func = Void Function();
typedef SignDelegation = void Function();

final SignDelegation nativeSignDelegation = dynamicLibrary
    .lookup<NativeFunction<sign_delegation_func>>('native_signDelegation')
    .asFunction();

// Scalar priv_key = { 0xca14d6eed923f6e3, 0x61185a1b5e29e6b2, 0xe26d38de9c30753b, 0x3fdf0efb0a5714 };


// C publickey function - void dart_publickey(unsigned char *sk, unsigned char *pk);
typedef publickey_func = Void Function(Pointer<Uint8> x, Pointer<Uint8> y);
typedef Publickey = void Function(Pointer<Uint8> x, Pointer<Uint8> y);
final void Function(Pointer<Uint8>, Pointer<Uint8>) pubkeyFunc = dynamicLibrary
    .lookup<NativeFunction<publickey_func>>('native_generate_global_keypair')
    .asFunction<Publickey>();

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
final SignUserCommand signUserCommandFunc = dynamicLibrary
    .lookup<NativeFunction<sign_user_command_func>>('native_sign_user_command')
    .asFunction<SignUserCommand>();

void signUserCommand() {
  String memo = 'this is a memo';
  String feePayerAddress = 'B62qiy32p8kAKnny8ZFwoMhYpBppM1DWVCqAPBYNcXnsAHhnfAAuXgg';
  String senderAddress = 'B62qiy32p8kAKnny8ZFwoMhYpBppM1DWVCqAPBYNcXnsAHhnfAAuXgg';
  String receiverAddress = 'B62qrcFstkpqXww1EkSGrqMCwCNho86kuqBd4FrAAUsPxNKdiPzAUsy';
  int fee = 3;
  int feeToken = 1;
  int nonce = 200;
  int validUntil = 10000;
  int tokenId = 1;
  int amount = 42;
  int txType = 0;
  int tokenLocked = 0;
  final field = allocate<Uint8>(count: 78);
  final scalar = allocate<Uint8>(count: 78);

  signUserCommandFunc(
    MinaHelper.bytesToPointer(MinaHelper.stringToBytesUtf8(memo)),
    MinaHelper.bytesToPointer(MinaHelper.stringToBytesUtf8(feePayerAddress)),
    MinaHelper.bytesToPointer(MinaHelper.stringToBytesUtf8(senderAddress)),
    MinaHelper.bytesToPointer(MinaHelper.stringToBytesUtf8(receiverAddress)),
    fee,
    feeToken,
    nonce,
    validUntil,
    tokenId,
    amount,
    tokenLocked,
    txType,
    field,
    scalar
  );
  
//  print('===== field: ${field.asTypedList(78)}');

  String string = String.fromCharCodes(field.asTypedList(77));
  print('===== field: $string');
  String string1 = String.fromCharCodes(scalar.asTypedList(77));
  print('===== field: $string1');
}

class CompressedPublicKey {
  Uint8List x;
  Uint8List isOdd;
}

// Get public key from secret key
CompressedPublicKey getCompressedPubicKey() {
  final x = allocate<Uint8>(count: 32);
  final y = allocate<Uint8>(count: 1);

  pubkeyFunc(x, y);
//  free(pointer);
  CompressedPublicKey rawPublicKey = CompressedPublicKey();
  rawPublicKey.x = x.asTypedList(32);
  rawPublicKey.isOdd = y.asTypedList(1);
  return rawPublicKey;
}

final sha256digest = SHA256Digest();
/// Used for the Base58 encoding.
const String alphabet =
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

String getAddress() {
  CompressedPublicKey compressedPublicKey = getCompressedPubicKey();

  Uint8List payload = Uint8List(40);
  payload[0] = 0xcb;
  payload[1] = 0x01;
  payload[2] = 0x01;
  for(int i = 0; i < compressedPublicKey.x.length; i++) {
    payload[3 + i] = compressedPublicKey.x[i];
  }

  payload[35] = compressedPublicKey.isOdd[0];
  Uint8List checksum = sha256digest.process(sha256digest.process(payload.sublist(0, 36)));

  payload[36] = checksum[0];
  payload[37] = checksum[1];
  payload[38] = checksum[2];
  payload[39] = checksum[3];

  String address = Base58Codec(alphabet).encode(payload);
  return address;
}

void testInvalidBase58Enc() {
  //0f 48 c6 5b d2 5f 85 f3 e4 ea 4e fe be b7 5b 79 7b d7 43 60 3b e0 4b 4e ad 84 56 98 b7 6b d3 31
  Uint8List src = Uint8List(36);
  src[0] = 0xcb; src[1] = 0x01; src[2] = 0x01;

  src[3] = 0x02; src[4] = 0x02; src[5] = 0x02; src[6] = 0x02; src[7] = 0x02; src[8] = 0x02; src[9] = 0x02; src[10] = 0x02;
  src[11] = 0x02; src[12] = 0x02; src[13] = 0x02; src[14] = 0x02; src[15] = 0x02; src[16] = 0x02; src[17] = 0x02; src[18] = 0x02;
  src[19] = 0x02; src[20] = 0x02; src[21] = 0x02; src[22] = 0x02; src[23] = 0x02; src[24] = 0x02; src[25] = 0x02; src[26] = 0x02;
  src[27] = 0x02; src[28] = 0x02; src[29] = 0x02; src[30] = 0x02; src[31] = 0x02; src[32] = 0x02; src[33] = 0x02; src[34] = 0x02;

  src[35] = 0x00;

  Uint8List hashed = sha256digest.process(sha256digest.process(src));
  Uint8List compressedKey = Uint8List(40);
  for(int i = 0; i < src.length; i++) {
    compressedKey[i] = src[i];
  }
  compressedKey[36] = hashed[0];
  compressedKey[37] = hashed[1];
  compressedKey[38] = hashed[2];
  compressedKey[39] = hashed[3];

  String address = Base58Codec(alphabet).encode(compressedKey);
  print('----------------------- Invalid: $address ---------------------');
}

void testBase58Enc() {
  //0f 48 c6 5b d2 5f 85 f3 e4 ea 4e fe be b7 5b 79 7b d7 43 60 3b e0 4b 4e ad 84 56 98 b7 6b d3 31
  Uint8List src = Uint8List(36);
  src[0] = 0xcb; src[1] = 0x01; src[2] = 0x01;

  src[3] = 0x0f; src[4] = 0x48; src[5] = 0xc6; src[6] = 0x5b; src[7] = 0xd2; src[8] = 0x5f; src[9] = 0x85; src[10] = 0xf3;
  src[11] = 0xe4; src[12] = 0xea; src[13] = 0x4e; src[14] = 0xfe; src[15] = 0xbe; src[16] = 0xb7; src[17] = 0x5b; src[18] = 0x79;
  src[19] = 0x7b; src[20] = 0xd7; src[21] = 0x43; src[22] = 0x60; src[23] = 0x3b; src[24] = 0xe0; src[25] = 0x4b; src[26] = 0x4e;
  src[27] = 0xad; src[28] = 0x84; src[29] = 0x56; src[30] = 0x98; src[31] = 0xb7; src[32] = 0x6b; src[33] = 0xd3; src[34] = 0x31;

  src[35] = 0x00;

  Uint8List hashed = sha256digest.process(sha256digest.process(src));
  Uint8List compressedKey = Uint8List(40);
  for(int i = 0; i < src.length; i++) {
    compressedKey[i] = src[i];
  }
  compressedKey[36] = hashed[0];
  compressedKey[37] = hashed[1];
  compressedKey[38] = hashed[2];
  compressedKey[39] = hashed[3];

  String address = Base58Codec(alphabet).encode(compressedKey);
  print('----------------------- $address ---------------------');
}