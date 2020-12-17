import 'dart:ffi';
import 'dart:typed_data';
import 'package:base58check/base58.dart';
import 'package:ffi/ffi.dart';
import 'package:ffi_mina_signer/types/key_types.dart';
import 'package:ffi_mina_signer/util/mina_helper.dart';
import 'global/global.dart';
import 'libmina_signer_binding.dart';

// Get compressed public key from secret key
CompressedPublicKey getCompressedPubicKey(Uint8List sk) {
  final x = allocate<Uint8>(count: 32);
  final isOdd = allocate<Uint8>(count: 1);
  final skPointer = MinaHelper.copyBytesToPointer(sk);

  pubkeyFunc(skPointer, x, isOdd);

  CompressedPublicKey rawPublicKey = CompressedPublicKey(x.asTypedList(32), isOdd.asTypedList(1));
  free(x);
  free(isOdd);
  free(skPointer);
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

// Get address from secret key
String getAddressFromSecretKey(Uint8List sk) {
  CompressedPublicKey compressedPublicKey = getCompressedPubicKey(sk);
  return getAddressFromPublicKey(compressedPublicKey);
}

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
      MinaHelper.copyBytesToPointer(MinaHelper.stringToBytesUtf8(memo)),
      MinaHelper.copyBytesToPointer(MinaHelper.stringToBytesUtf8(feePayerAddress)),
      MinaHelper.copyBytesToPointer(MinaHelper.stringToBytesUtf8(senderAddress)),
      MinaHelper.copyBytesToPointer(MinaHelper.stringToBytesUtf8(receiverAddress)),
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

  print('===== field: ${MinaHelper.byteToBigInt(field.asTypedList(78))}');

  String string = String.fromCharCodes(field.asTypedList(77));
  print('===== field: $string');
  String string1 = String.fromCharCodes(scalar.asTypedList(77));
  print('===== field: $string1');
}


