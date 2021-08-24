import 'dart:ffi';
import 'dart:typed_data';
import 'package:base58check/base58.dart';
import 'package:bitcoin_bip32/bitcoin_bip32.dart';
import 'package:convert/convert.dart';
import 'package:ffi/ffi.dart';
import 'package:ffi_mina_signer/encrypt/crypter.dart';
import 'package:ffi_mina_signer/types/key_types.dart';
import 'package:ffi_mina_signer/util/mina_helper.dart';
import 'package:flutter/foundation.dart';
import '../constant.dart';
import '../global/global.dart';
import 'libmina_signer_binding.dart';
import '../types/key_types.dart';
import 'package:bip39/bip39.dart' as bip39;

// Return a string of 12 words joined with space
String generateMnemonic() {
  var mnemonic = bip39.generateMnemonic();
  return mnemonic;
}

Future<Uint8List> mnemonicToSeed(String mnemonic) async {
  return await compute(bip39.mnemonicToSeed, mnemonic);
}

bool validateMnemonic(String mnemonic) {
  return bip39.validateMnemonic(mnemonic);
}

/// Encrypt the seed, then we can store them in our disk space
/// @param sodium What lib will be used for cipher, if
///        true: default sodium will be used with argon2id+XChaCha20Poly1305Ietf
///        false: pointycastle will be used, however, this approach is deprecated.
Future<String> encryptSeed(Uint8List seed, String password, { bool sodium = true }) async {
  Uint8List encrypted = await MinaCryptor.encrypt(seed, password, sodium: sodium);
  // String representation:
  String encryptedSeedHex = MinaHelper.byteToHex(encrypted);
  return encryptedSeedHex;
}

Future<Uint8List> decryptSeed(String encryptedSeedHex, String password) async {
  Uint8List decrypted = await MinaCryptor.decrypt(
    MinaHelper.hexToBytes(encryptedSeedHex), password);

  return decrypted;
}

// Use seed to generate account private key, according to HD wallet spec
Uint8List generatePrivateKey(Uint8List seed, int account) {
//   m / purpose' / coin_type' / account' / change / address_index
  Chain chain = Chain.seed(hex.encode(seed));
  ExtendedPrivateKey? extendedPrivateKey = chain.forPath("m/44'/$MINA_COIN_TYPE'/$account'/0/0") as ExtendedPrivateKey?;
  // Decode the BigInt of seed to big-endian Uint8List
  Uint8List actualKey = MinaHelper.bigIntToBytes(extendedPrivateKey!.key!);
  // Make sure the private key is in [0, p)
  //
  // Note: Mina does rejection sampling to obtain a private key in
  // [0, p), where the field modulus
  //
  //     p = 28948022309329048855892746252171976963363056481941560715954676764349967630337
  //
  // Due to constraints, this implementation take a different
  // approach and just unsets the top two bits of the 256bit bip44
  // secret, so
  //
  //     max = 28948022309329048855892746252171976963317496166410141009864396001978282409983.
  //
  // If p < max then we could still generate invalid private keys
  // (although it's highly unlikely), but
  //
  //     p - max = 45560315531419706090280762371685220354
  //
  // Thus, we cannot generate invalid private keys and instead lose an
  // insignificant amount of entropy.
  actualKey[0] &= 0x3f; // Drop top two bits
  // The bit integer store in dart vm with big endian, convert it to little endian for C usage

  // Pay attention, this Uint8List is not a montgomery number, before using, a call to
  // fiat_pasta_fq_to_montgomery should happen
  // Little-endian convert should happend before pass this private key to C layer
  return actualKey;
}

// Get compressed public key from secret key
CompressedPublicKey getCompressedPubicKey(Uint8List sk) {
  final x = calloc<Uint8>(32);
  final isOdd = calloc<Uint8>(1);
  final skPointer = MinaHelper.copyBytesToPointer(sk);

  publicKeyFunc(skPointer, x, isOdd);

  CompressedPublicKey rawPublicKey = CompressedPublicKey(x.asTypedList(32), isOdd.asTypedList(1));
  calloc.free(x);
  calloc.free(isOdd);
  calloc.free(skPointer);
  return rawPublicKey;
}

// Get address from secret key
String getAddressFromPublicKey(CompressedPublicKey compressedPublicKey) {
  Uint8List payload = Uint8List(40);
  payload[0] = 0xcb;
  payload[1] = 0x01;
  payload[2] = 0x01;
  for(int i = 0; i < compressedPublicKey.x.length; i++) {
    payload[3 + i] = compressedPublicKey.x[i];
  }

  payload[35] = compressedPublicKey.isOdd[0];
  Uint8List checksum = gSHA256Digest.process(gSHA256Digest.process(payload.sublist(0, 36)));

  payload[36] = checksum[0];
  payload[37] = checksum[1];
  payload[38] = checksum[2];
  payload[39] = checksum[3];

  String address = Base58Codec(gBase58Alphabet).encode(payload);
  return address;
}

String decodeBase58Check(String? encoded) {
  if(null == encoded || encoded.isEmpty) {
    return '';
  }

  try {
    List<int> decodedBytes = Base58Codec(gBase58Alphabet).decode(encoded);
    if(null == decodedBytes || decodedBytes.length < 8) {
      // decode failed
      return encoded;
    }

    // Remove leading prefix and tailed checksum bytes
    List<int> contentBytes = decodedBytes.sublist(3, decodedBytes.length - 4);

    int i = 0;
    for(; i < contentBytes.length; i++) {
      if(contentBytes[i] == 0) {
        break;
      }
    }

    if(i == 0) {
      return '';
    }

    return String.fromCharCodes(contentBytes.sublist(0, i));
  } catch(e) {
    // This string maybe not base58check encoded, return the origin source
    return encoded;
  }
}

// Get address from secret key
String getAddressFromSecretKey(Uint8List sk) {
  CompressedPublicKey compressedPublicKey = getCompressedPubicKey(sk);
  return getAddressFromPublicKey(compressedPublicKey);
}

// Get address from secret key
Future<String> getAddressFromSecretKeyAsync(Uint8List sk) async {
//  return await compute(getAddressFromSecretKey, sk);
  return getAddressFromSecretKey(sk);
}

Future<Signature> signPayment(
  Uint8List sk,
  String memo,
  String feePayerAddress,
  String senderAddress,
  String receiverAddress,
  BigInt fee,
  BigInt feeToken,
  int nonce,
  int validUntil,
  BigInt tokenId,
  BigInt amount,
  int tokenLocked,
  int networkId
  ) async {
  Transaction transaction = Transaction(sk, memo, feePayerAddress, senderAddress, receiverAddress,
    fee, feeToken, nonce, validUntil, tokenId, amount, TRANSACTION_TYPE, tokenLocked, networkId);
//  return await compute(_signUserCommand, transaction);
  return _signUserCommand(transaction);
}

Future<Signature> signDelegation (
  Uint8List sk,
  String memo,
  String feePayerAddress,
  String senderAddress,
  String receiverAddress,
  BigInt fee,
  BigInt feeToken,
  int nonce,
  int validUntil,
  BigInt tokenId,
  int tokenLocked,
  int networkId
  ) async {
  Transaction transaction = Transaction(sk, memo, feePayerAddress, senderAddress, receiverAddress,
    fee, feeToken, nonce, validUntil, tokenId, BigInt.from(0), DELEGATION_TYPE, tokenLocked, networkId);
//  return await compute(_signUserCommand, transaction);
  return _signUserCommand(transaction);
}

// Sign user command
Signature _signUserCommand(Transaction transaction) {
  final field = calloc<Uint8>(SIGNATURE_FIELD_LENGTH);
  final fieldLength = calloc<Uint8>(1);
  final scalar = calloc<Uint8>(SIGNATURE_SCALAR_LENGTH);
  final scalarLength = calloc<Uint8>(1);
  final skPointer = MinaHelper.copyBytesToPointer(transaction.sk);
  final memoPointer = MinaHelper.copyStringToPointer(MinaHelper.stringToBytesUtf8(transaction.memo));
  final feePayerPointer = MinaHelper.copyStringToPointer(MinaHelper.stringToBytesUtf8(transaction.feePayerAddress));
  final senderPointer = MinaHelper.copyStringToPointer(MinaHelper.stringToBytesUtf8(transaction.senderAddress));
  final receiverPointer = MinaHelper.copyStringToPointer(MinaHelper.stringToBytesUtf8(transaction.receiverAddress));
  Uint8List feeBytes = MinaHelper.reverse(MinaHelper.uint64ToBytes(transaction.fee));
  final feePointer = MinaHelper.copyBytesToPointer(feeBytes);
  Uint8List feeTokenBytes = MinaHelper.reverse(MinaHelper.uint64ToBytes(transaction.feeToken));
  final feeTokenPointer = MinaHelper.copyBytesToPointer(feeTokenBytes);
  Uint8List amountBytes = MinaHelper.reverse(MinaHelper.uint64ToBytes(transaction.amount));
  final amountPointer = MinaHelper.copyBytesToPointer(amountBytes);
  Uint8List tokenIdBytes = MinaHelper.reverse(MinaHelper.uint64ToBytes(transaction.tokenId));
  final tokenIdPointer = MinaHelper.copyBytesToPointer(tokenIdBytes);

  signUserCommandFunc(
    skPointer,
    memoPointer,
    feePayerPointer,
    senderPointer,
    receiverPointer,
    feePointer,
    feeTokenPointer,
    transaction.nonce,
    transaction.validUntil,
    tokenIdPointer,
    amountPointer,
    transaction.tokenLocked,
    transaction.txType,
    field,
    fieldLength,
    scalar,
    scalarLength,
    transaction.networkId
  );

  // Read Dart string from C string
  Uint8List fieldList = field.asTypedList(SIGNATURE_FIELD_LENGTH);
  Uint8List fieldLengthList = fieldLength.asTypedList(1);
  String fieldStr = String.fromCharCodes(fieldList.sublist(0, fieldLengthList[0]));
  Uint8List scalarList = scalar.asTypedList(SIGNATURE_SCALAR_LENGTH);
  Uint8List scalarLengthList = scalarLength.asTypedList(1);
  String scalarStr = String.fromCharCodes(scalarList.sublist(0, scalarLengthList[0]));

  calloc.free(field);
  calloc.free(scalar);
  calloc.free(skPointer);
  calloc.free(memoPointer);
  calloc.free(feePayerPointer);
  calloc.free(senderPointer);
  calloc.free(receiverPointer);
  calloc.free(fieldLength);
  calloc.free(scalarLength);
  calloc.free(feePointer);
  calloc.free(feeTokenPointer);
  calloc.free(amountPointer);
  calloc.free(tokenIdPointer);

  return Signature(fieldStr, scalarStr);
}


