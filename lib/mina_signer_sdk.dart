import 'dart:ffi';
import 'dart:typed_data';
import 'package:base58check/base58.dart';
import 'package:ffi/ffi.dart';
import 'package:ffi_mina_signer/types/key_types.dart';
import 'package:ffi_mina_signer/util/mina_helper.dart';
import 'constant.dart';
import 'global/global.dart';
import 'libmina_signer_binding.dart';
import 'types/key_types.dart';

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

Signature signTransaction(
    Uint8List sk,
    String memo,
    String feePayerAddress,
    String senderAddress,
    String receiverAddress,
    int fee,
    int feeToken,
    int nonce,
    int validUntil,
    int tokenId,
    int amount,
    int tokenLocked
    ) {
  return _signUserCommand(sk, memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken,
      nonce, validUntil, tokenId, amount, TRANSACTION_TYPE, tokenLocked);
}

Signature signDelegation(
    Uint8List sk,
    String memo,
    String feePayerAddress,
    String senderAddress,
    String receiverAddress,
    int fee,
    int feeToken,
    int nonce,
    int validUntil,
    int tokenId,
    int tokenLocked
    ) {
  return _signUserCommand(sk, memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken,
      nonce, validUntil, tokenId, 0, DELEGATION_TYPE, tokenLocked);
}

// Sign user command
Signature _signUserCommand(
    Uint8List sk,
    String memo,
    String feePayerAddress,
    String senderAddress,
    String receiverAddress,
    int fee,
    int feeToken,
    int nonce,
    int validUntil,
    int tokenId,
    int amount,
    int txType,
    int tokenLocked
    ) {
  final field = allocate<Uint8>(count: SIGNATURE_FIELD_LENGTH);
  final scalar = allocate<Uint8>(count: SIGNATURE_SCALAR_LENGTH);
  final skPointer = MinaHelper.copyBytesToPointer(sk);
  final memoPointer = MinaHelper.copyStringToPointer(MinaHelper.stringToBytesUtf8(memo));
  final feePayerPointer = MinaHelper.copyStringToPointer(MinaHelper.stringToBytesUtf8(feePayerAddress));
  final senderPointer = MinaHelper.copyStringToPointer(MinaHelper.stringToBytesUtf8(senderAddress));
  final receiverPointer = MinaHelper.copyStringToPointer(MinaHelper.stringToBytesUtf8(receiverAddress));

  signUserCommandFunc(
      skPointer,
      memoPointer,
      feePayerPointer,
      senderPointer,
      receiverPointer,
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

  // Drop the ending 0 byte of C char string
  int endIndex;
  Uint8List fieldList = field.asTypedList(SIGNATURE_FIELD_LENGTH);
  endIndex = fieldList.indexOf(0);
  String fieldStr = String.fromCharCodes(fieldList.sublist(0, endIndex));
  Uint8List scalarList = scalar.asTypedList(SIGNATURE_SCALAR_LENGTH);
  endIndex = scalarList.indexOf(0);
  String scalarStr = String.fromCharCodes(scalarList.sublist(0, endIndex));

  free(field);
  free(scalar);
  free(skPointer);
  free(memoPointer);
  free(feePayerPointer);
  free(senderPointer);
  free(receiverPointer);

  return Signature(fieldStr, scalarStr);
}


