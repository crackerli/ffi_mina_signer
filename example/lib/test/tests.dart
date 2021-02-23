import 'dart:typed_data';

import 'package:base58check/base58.dart';
import 'package:convert/convert.dart';
import 'package:ffi_mina_signer/encrypt/crypter.dart';
import 'package:ffi_mina_signer/global/global.dart';
import 'package:ffi_mina_signer/sdk/mina_signer_sdk.dart';
import 'package:ffi_mina_signer/types/key_types.dart';
import 'package:bitcoin_bip32/bitcoin_bip32.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ffi_mina_signer/util/mina_helper.dart';

const String _LedgerTestWords =
  "course grief vintage slim tell hospital car maze model style elegant kitchen state purpose matrix gas grid enable frown road goddess glove canyon key";

void testBase58Enc() {
  //0f 48 c6 5b d2 5f 85 f3 e4 ea 4e fe be b7 5b 79 7b d7 43 60 3b e0 4b 4e ad 84 56 98 b7 6b d3 31
  Uint8List src = Uint8List(36);
  src[0] = 0xcb; src[1] = 0x01; src[2] = 0x01;

  src[3] = 0x0f; src[4] = 0x48; src[5] = 0xc6; src[6] = 0x5b; src[7] = 0xd2; src[8] = 0x5f; src[9] = 0x85; src[10] = 0xf3;
  src[11] = 0xe4; src[12] = 0xea; src[13] = 0x4e; src[14] = 0xfe; src[15] = 0xbe; src[16] = 0xb7; src[17] = 0x5b; src[18] = 0x79;
  src[19] = 0x7b; src[20] = 0xd7; src[21] = 0x43; src[22] = 0x60; src[23] = 0x3b; src[24] = 0xe0; src[25] = 0x4b; src[26] = 0x4e;
  src[27] = 0xad; src[28] = 0x84; src[29] = 0x56; src[30] = 0x98; src[31] = 0xb7; src[32] = 0x6b; src[33] = 0xd3; src[34] = 0x31;

  src[35] = 0x00;

  Uint8List hashed = gSHA256Digest.process(gSHA256Digest.process(src));
  Uint8List compressedKey = Uint8List(40);
  for(int i = 0; i < src.length; i++) {
    compressedKey[i] = src[i];
  }
  compressedKey[36] = hashed[0];
  compressedKey[37] = hashed[1];
  compressedKey[38] = hashed[2];
  compressedKey[39] = hashed[3];

  String address = Base58Codec(gBase58Alphabet).encode(compressedKey);
  print('----------------------- $address ---------------------');
}

//Scalar priv_key = { 0xca14d6eed923f6e3, 0x61185a1b5e29e6b2, 0xe26d38de9c30753b, 0x3fdf0efb0a5714 };
void testGetAddressFromSecretKey() {
  Uint8List sk = Uint8List(32);
  sk[0]  = 0xe3; sk[1]  = 0xf6; sk[2]  = 0x23; sk[3]  = 0xd9; sk[4]  = 0xee; sk[5]  = 0xd6; sk[6]  = 0x14; sk[7]  = 0xca;
  sk[8]  = 0xb2; sk[9]  = 0xe6; sk[10] = 0x29; sk[11] = 0x5e; sk[12] = 0x1b; sk[13] = 0x5a; sk[14] = 0x18; sk[15] = 0x61;
  sk[16] = 0x3b; sk[17] = 0x75; sk[18] = 0x30; sk[19] = 0x9c; sk[20] = 0xde; sk[21] = 0x38; sk[22] = 0x6d; sk[23] = 0xe2;
  sk[24] = 0x14; sk[25] = 0x57; sk[26] = 0x0a; sk[27] = 0xfb; sk[28] = 0x0e; sk[29] = 0xdf; sk[30] = 0x3f; sk[31] = 0x00;

  String address = getAddressFromSecretKey(sk);
  print('----------------------- $address -----------------------');
}

Future<void> testSignTransaction() async {
  Uint8List sk = Uint8List(32);
  sk[0]  = 0xe3; sk[1]  = 0xf6; sk[2]  = 0x23; sk[3]  = 0xd9; sk[4]  = 0xee; sk[5]  = 0xd6; sk[6]  = 0x14; sk[7]  = 0xca;
  sk[8]  = 0xb2; sk[9]  = 0xe6; sk[10] = 0x29; sk[11] = 0x5e; sk[12] = 0x1b; sk[13] = 0x5a; sk[14] = 0x18; sk[15] = 0x61;
  sk[16] = 0x3b; sk[17] = 0x75; sk[18] = 0x30; sk[19] = 0x9c; sk[20] = 0xde; sk[21] = 0x38; sk[22] = 0x6d; sk[23] = 0xe2;
  sk[24] = 0x14; sk[25] = 0x57; sk[26] = 0x0a; sk[27] = 0xfb; sk[28] = 0x0e; sk[29] = 0xdf; sk[30] = 0x3f; sk[31] = 0x00;
  String memo = 'this is a memo';
  String feePayerAddress = 'B62qiy32p8kAKnny8ZFwoMhYpBppM1DWVCqAPBYNcXnsAHhnfAAuXgg';
  String senderAddress = 'B62qiy32p8kAKnny8ZFwoMhYpBppM1DWVCqAPBYNcXnsAHhnfAAuXgg';
  String receiverAddress = 'B62qrcFstkpqXww1EkSGrqMCwCNho86kuqBd4FrAAUsPxNKdiPzAUsy';
  BigInt fee = BigInt.from(3);
  BigInt feeToken = BigInt.from(1);
  int nonce = 200;
  int validUntil = 10000;
  BigInt tokenId = BigInt.from(1);
  BigInt amount = BigInt.from(42);
  int tokenLocked = 0;

  Signature signature = await signPayment(sk, memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken, nonce, validUntil, tokenId, amount, tokenLocked);
  print('---------------------- test sign Izzy tx signature rx=${signature.rx} ------------------');
  print('---------------------- test sign Izzy tx signature s=${signature.s} ------------------');
}

Future<void> testSignDelegation() async {
  Uint8List sk = Uint8List(32);
  sk[0]  = 0xe3; sk[1]  = 0xf6; sk[2]  = 0x23; sk[3]  = 0xd9; sk[4]  = 0xee; sk[5]  = 0xd6; sk[6]  = 0x14; sk[7]  = 0xca;
  sk[8]  = 0xb2; sk[9]  = 0xe6; sk[10] = 0x29; sk[11] = 0x5e; sk[12] = 0x1b; sk[13] = 0x5a; sk[14] = 0x18; sk[15] = 0x61;
  sk[16] = 0x3b; sk[17] = 0x75; sk[18] = 0x30; sk[19] = 0x9c; sk[20] = 0xde; sk[21] = 0x38; sk[22] = 0x6d; sk[23] = 0xe2;
  sk[24] = 0x14; sk[25] = 0x57; sk[26] = 0x0a; sk[27] = 0xfb; sk[28] = 0x0e; sk[29] = 0xdf; sk[30] = 0x3f; sk[31] = 0x00;
  String memo = 'more delegates, more fun';
  String feePayerAddress = 'B62qiy32p8kAKnny8ZFwoMhYpBppM1DWVCqAPBYNcXnsAHhnfAAuXgg';
  String senderAddress = 'B62qiy32p8kAKnny8ZFwoMhYpBppM1DWVCqAPBYNcXnsAHhnfAAuXgg';
  String receiverAddress = 'B62qkfHpLpELqpMK6ZvUTJ5wRqKDRF3UHyJ4Kv3FU79Sgs4qpBnx5RR';
  BigInt fee = BigInt.from(3);
  BigInt feeToken = BigInt.from(1);
  int nonce = 10;
  int validUntil = 4000;
  BigInt tokenId = BigInt.from(1);
  int tokenLocked = 0;

  Signature signature = await signDelegation(sk, memo, feePayerAddress, senderAddress,
      receiverAddress, fee, feeToken, nonce, validUntil, tokenId, tokenLocked);

  print('---------------------- signature rx=${signature.rx} ------------------');
  print('---------------------- signature s=${signature.s} ------------------');
}

void testBIP44() async {
  var mnemonic = bip39.generateMnemonic();
  print('---------------- $mnemonic ----------------------');
  String seed = bip39.mnemonicToSeedHex(_LedgerTestWords);//bip39.mnemonicToSeedHex(mnemonic);
  Uint8List seed1 = bip39.mnemonicToSeed(mnemonic);
  Uint8List seedBytes = MinaHelper.hexToBytes(seed);
//   m / purpose' / coin_type' / account' / change / address_index
  Chain chain = Chain.seed(hex.encode(MinaHelper.hexToBytes(seed)));
  Chain chain1 = Chain.seed(hex.encode(seed1));
  // ExtendedPrivateKey key = chain.forPath("m/44'/12586'/0'/0/0");
  // ExtendedPrivateKey key10 = chain.forPath("m/44'/12586'/0'/0/0");
  // ExtendedPrivateKey key1 = chain1.forPath("m/44'/12586'/0'/0/0");

  // Encrypting and decrypting a seed
  Uint8List encrypted = MinaCryptor.encrypt(seed, 'thisisastrongpassword');
  print('encrypted=$encrypted');
  // String representation:
  String encryptedSeedHex = MinaHelper.byteToHex(encrypted);
  // Decrypting (if incorrect password, will throw an exception)
  Uint8List decrypted = MinaCryptor.decrypt(
      MinaHelper.hexToBytes(encryptedSeedHex), 'thisisastrongpassword');
  print('decrypted = ${MinaHelper.byteToHex(decrypted)}');
  print('origin = ${MinaHelper.byteToHex(seedBytes)}');
}

/// Result public key should be: B62qnzbXmRNo9q32n4SNu2mpB8e7FYYLH8NmaX6oFCBYjjQ8SbD7uzV
Future<bool> testAccount0() async {
  Uint8List seed = bip39.mnemonicToSeed(_LedgerTestWords);
  Uint8List account0Priv = generatePrivateKey(seed, 0);
  String address = await getAddressFromSecretKeyAsync(MinaHelper.reverse(account0Priv));
  bool testRet = 'B62qnzbXmRNo9q32n4SNu2mpB8e7FYYLH8NmaX6oFCBYjjQ8SbD7uzV' == address;
  print('=================== testAccount0 passed: $testRet ================');
  return testRet;
}

/// Result public key should be: B62qicipYxyEHu7QjUqS7QvBipTs5CzgkYZZZkPoKVYBu6tnDUcE9Zt
Future<bool> testAccount1() async {
  Uint8List seed = bip39.mnemonicToSeed(_LedgerTestWords);
  Uint8List account1Priv = generatePrivateKey(seed, 1);
  String address = await getAddressFromSecretKeyAsync(MinaHelper.reverse(account1Priv));
  bool testRet = 'B62qicipYxyEHu7QjUqS7QvBipTs5CzgkYZZZkPoKVYBu6tnDUcE9Zt' == address;
  print('=================== testAccount1 passed: $testRet ================');
  return testRet;
}

/// Result public key should be: B62qrKG4Z8hnzZqp1AL8WsQhQYah3quN1qUj3SyfJA8Lw135qWWg1mi
Future<bool> testAccount2() async {
  Uint8List seed = bip39.mnemonicToSeed(_LedgerTestWords);
  Uint8List account2Priv = generatePrivateKey(seed, 2);
  String address = await getAddressFromSecretKeyAsync(MinaHelper.reverse(account2Priv));
  bool testRet = 'B62qrKG4Z8hnzZqp1AL8WsQhQYah3quN1qUj3SyfJA8Lw135qWWg1mi' == address;
  print('=================== testAccount2 passed: $testRet ================');
  return testRet;
}

/// Result public key should be: B62qoqiAgERjCjXhofXiD7cMLJSKD8hE8ZtMh4jX5MPNgKB4CFxxm1N
Future<bool> testAccount3() async {
  Uint8List seed = bip39.mnemonicToSeed(_LedgerTestWords);
  Uint8List account3Priv = generatePrivateKey(seed, 3);
  String address = await getAddressFromSecretKeyAsync(MinaHelper.reverse(account3Priv));
  bool testRet = 'B62qoqiAgERjCjXhofXiD7cMLJSKD8hE8ZtMh4jX5MPNgKB4CFxxm1N' == address;
  print('=================== testAccount3 passed: $testRet ================');
  return testRet;
}

/// Result public key should be: B62qkiT4kgCawkSEF84ga5kP9QnhmTJEYzcfgGuk6okAJtSBfVcjm1M
Future<bool> testAccount49370() async {
  Uint8List seed = bip39.mnemonicToSeed(_LedgerTestWords);
  Uint8List account49370Priv = generatePrivateKey(seed, 49370);
  String address = await getAddressFromSecretKeyAsync(MinaHelper.reverse(account49370Priv));
  bool testRet = 'B62qkiT4kgCawkSEF84ga5kP9QnhmTJEYzcfgGuk6okAJtSBfVcjm1M' == address;
  print('=================== testAccount49370 passed: $testRet ================');
  return testRet;
}

/// Result public key should be: B62qoG5Yk4iVxpyczUrBNpwtx2xunhL48dydN53A2VjoRwF8NUTbVr4
Future<bool> testAccount12586() async {
  Uint8List seed = bip39.mnemonicToSeed(_LedgerTestWords);
  Uint8List account12586Priv = generatePrivateKey(seed, 12586);
  String address = await getAddressFromSecretKeyAsync(MinaHelper.reverse(account12586Priv));
  bool testRet = 'B62qoG5Yk4iVxpyczUrBNpwtx2xunhL48dydN53A2VjoRwF8NUTbVr4' == address;
  print('=================== testAccount12586 passed: $testRet ================');
  return testRet;
}

Future<bool> testSignPayment0() async {
  Uint8List sk = MinaHelper.hexToBytes('164244176fddb5d769b7de2027469d027ad428fadcc0c02396e6280142efb718');
  String memo = 'Hello Mina!';
  String feePayerAddress = 'B62qnzbXmRNo9q32n4SNu2mpB8e7FYYLH8NmaX6oFCBYjjQ8SbD7uzV';
  String senderAddress = 'B62qnzbXmRNo9q32n4SNu2mpB8e7FYYLH8NmaX6oFCBYjjQ8SbD7uzV';
  String receiverAddress = 'B62qicipYxyEHu7QjUqS7QvBipTs5CzgkYZZZkPoKVYBu6tnDUcE9Zt';
  BigInt fee = BigInt.from(2000000000);
  BigInt feeToken = BigInt.from(1);
  int nonce = 16;
  int validUntil = 271828;
  BigInt tokenId = BigInt.from(1);
  BigInt amount = BigInt.from(1729000000000);
  int tokenLocked = 0;

  Signature signature = await signPayment(MinaHelper.reverse(sk), memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken, nonce, validUntil, tokenId, amount, tokenLocked);
  print('--signature rx=${signature.rx}--');
  print('--signature s=${signature.s}--');
  bool rxRet = signature.rx == '7978049910726616927075298742385001574587620942310654323357397558995139646406';
  bool sRet = signature.s == '3429352238474987065427486162608449491113877901219474382951875744532516739503';
  return rxRet && sRet;
}

Future<bool> testSignPayment1() async {
  Uint8List sk = MinaHelper.hexToBytes('3414fc16e86e6ac272fda03cf8dcb4d7d47af91b4b726494dab43bf773ce1779');
  String memo = '';
  String feePayerAddress = 'B62qoG5Yk4iVxpyczUrBNpwtx2xunhL48dydN53A2VjoRwF8NUTbVr4';
  String senderAddress = 'B62qoG5Yk4iVxpyczUrBNpwtx2xunhL48dydN53A2VjoRwF8NUTbVr4';
  String receiverAddress = 'B62qrKG4Z8hnzZqp1AL8WsQhQYah3quN1qUj3SyfJA8Lw135qWWg1mi';
  BigInt fee = BigInt.from(1618033988);
  BigInt feeToken = BigInt.from(1);
  int nonce = 0;
  int validUntil = 4294967295;
  BigInt tokenId = BigInt.from(1);
  BigInt amount = BigInt.from(314159265359);
  int tokenLocked = 0;

  Signature signature = await signPayment(MinaHelper.reverse(sk), memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken, nonce, validUntil, tokenId, amount, tokenLocked);
  print('--signature rx=${signature.rx}--');
  print('--signature s=${signature.s}--');
  bool rxRet = signature.rx == '16131108141714490926110640608740233251420702480413004179312159314226811492547';
  bool sRet = signature.s == '7997237918149661706021181699318196592527229183760864477363327520627837678207';
  return rxRet && sRet;
}

Future<bool> testSignPayment2() async {
  Uint8List sk = MinaHelper.hexToBytes('3414fc16e86e6ac272fda03cf8dcb4d7d47af91b4b726494dab43bf773ce1779');
  String memo = '01234567890123456789012345678901';
  String feePayerAddress = 'B62qoG5Yk4iVxpyczUrBNpwtx2xunhL48dydN53A2VjoRwF8NUTbVr4';
  String senderAddress = 'B62qoG5Yk4iVxpyczUrBNpwtx2xunhL48dydN53A2VjoRwF8NUTbVr4';
  String receiverAddress = 'B62qoqiAgERjCjXhofXiD7cMLJSKD8hE8ZtMh4jX5MPNgKB4CFxxm1N';
  BigInt fee = BigInt.from(100000);
  BigInt feeToken = BigInt.from(1);
  int nonce = 5687;
  int validUntil = 4294967295;
  BigInt tokenId = BigInt.from(1);
  BigInt amount = BigInt.from(271828182845904);
  int tokenLocked = 0;

  Signature signature = await signPayment(MinaHelper.reverse(sk), memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken, nonce, validUntil, tokenId, amount, tokenLocked);
  print('--signature rx=${signature.rx}--');
  print('--signature s=${signature.s}--');
  bool rxRet = signature.rx == '19585582528479034482936233270220146871772976333892177877926947867842051902219';
  bool sRet = signature.s == '1898932056963890979221410902912044544959664249879468621257581179780032066053';
  return rxRet && sRet;
}

Future<bool> testSignPayment3() async {
  Uint8List sk = MinaHelper.hexToBytes('1dee867358d4000f1dafa5978341fb515f89eeddbe450bd57df091f1e63d4444');
  String memo = '';
  String feePayerAddress = 'B62qoqiAgERjCjXhofXiD7cMLJSKD8hE8ZtMh4jX5MPNgKB4CFxxm1N';
  String senderAddress = 'B62qoqiAgERjCjXhofXiD7cMLJSKD8hE8ZtMh4jX5MPNgKB4CFxxm1N';
  String receiverAddress = 'B62qnzbXmRNo9q32n4SNu2mpB8e7FYYLH8NmaX6oFCBYjjQ8SbD7uzV';
  BigInt fee = BigInt.from(2000000000);
  BigInt feeToken = BigInt.from(1);
  int nonce = 0;
  int validUntil = 1982;
  BigInt tokenId = BigInt.from(1);
  BigInt amount = BigInt.from(0);
  int tokenLocked = 0;

  Signature signature = await signPayment(MinaHelper.reverse(sk), memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken, nonce, validUntil, tokenId, amount, tokenLocked);
  print('--signature rx=${signature.rx}--');
  print('--signature s=${signature.s}--');
  bool rxRet = signature.rx == '17066769773105242494055710444509755198478182140018572062281801805371237403781';
  bool sRet = signature.s == '4656919141901529966292781438366791373465090840262015566707274782775689902668';
  return rxRet && sRet;
}

Future<bool> testSignDelegation0() async {
  Uint8List sk = MinaHelper.hexToBytes('164244176fddb5d769b7de2027469d027ad428fadcc0c02396e6280142efb718');
  String memo = 'Delewho?';
  String feePayerAddress = 'B62qnzbXmRNo9q32n4SNu2mpB8e7FYYLH8NmaX6oFCBYjjQ8SbD7uzV';
  String senderAddress = 'B62qnzbXmRNo9q32n4SNu2mpB8e7FYYLH8NmaX6oFCBYjjQ8SbD7uzV';
  String receiverAddress = 'B62qicipYxyEHu7QjUqS7QvBipTs5CzgkYZZZkPoKVYBu6tnDUcE9Zt';
  BigInt fee = BigInt.from(2000000000);
  BigInt feeToken = BigInt.from(1);
  int nonce = 16;
  int validUntil = 1337;
  BigInt tokenId = BigInt.from(1);
  int tokenLocked = 0;

  Signature signature = await signDelegation(MinaHelper.reverse(sk), memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken, nonce, validUntil, tokenId, tokenLocked);
  print('--signature rx=${signature.rx}--');
  print('--signature s=${signature.s}--');
  bool rxRet = signature.rx == '21925671315558903310698147703936227434489670233822660143749268383293007278017';
  bool sRet = signature.s == '13899241708284436545519801194049913177669548839384946008100180949535333743108';
  return rxRet && sRet;
}

Future<bool> testSignDelegation1() async {
  Uint8List sk = MinaHelper.hexToBytes('20f84123a26e58dd32b0ea3c80381f35cd01bc22a20346cc65b0a67ae48532ba');
  String memo = '';
  String feePayerAddress = 'B62qkiT4kgCawkSEF84ga5kP9QnhmTJEYzcfgGuk6okAJtSBfVcjm1M';
  String senderAddress = 'B62qkiT4kgCawkSEF84ga5kP9QnhmTJEYzcfgGuk6okAJtSBfVcjm1M';
  String receiverAddress = 'B62qnzbXmRNo9q32n4SNu2mpB8e7FYYLH8NmaX6oFCBYjjQ8SbD7uzV';
  BigInt fee = BigInt.from(2000000000);
  BigInt feeToken = BigInt.from(1);
  int nonce = 0;
  int validUntil = 4294967295;
  BigInt tokenId = BigInt.from(1);
  int tokenLocked = 0;

  Signature signature = await signDelegation(MinaHelper.reverse(sk), memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken, nonce, validUntil, tokenId, tokenLocked);
  print('--signature rx=${signature.rx}--');
  print('--signature s=${signature.s}--');
  bool rxRet = signature.rx == '3579580815441305868810118809396705910374864465599837423758687880490203788411';
  bool sRet = signature.s == '27540384610272489000654948607668179894868840391954363231140328953866256474214';
  return rxRet && sRet;
}

Future<bool> testSignDelegation2() async {
  Uint8List sk = MinaHelper.hexToBytes('3414fc16e86e6ac272fda03cf8dcb4d7d47af91b4b726494dab43bf773ce1779');
  String memo = 'more delegates, more fun........';
  String feePayerAddress = 'B62qoG5Yk4iVxpyczUrBNpwtx2xunhL48dydN53A2VjoRwF8NUTbVr4';
  String senderAddress = 'B62qoG5Yk4iVxpyczUrBNpwtx2xunhL48dydN53A2VjoRwF8NUTbVr4';
  String receiverAddress = 'B62qkiT4kgCawkSEF84ga5kP9QnhmTJEYzcfgGuk6okAJtSBfVcjm1M';
  BigInt fee = BigInt.from(42000000000);
  BigInt feeToken = BigInt.from(1);
  int nonce = 1;
  int validUntil = 4294967295;
  BigInt tokenId = BigInt.from(1);
  int tokenLocked = 0;

  Signature signature = await signDelegation(MinaHelper.reverse(sk), memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken, nonce, validUntil, tokenId, tokenLocked);
  print('--signature rx=${signature.rx}--');
  print('--signature s=${signature.s}--');
  bool rxRet = signature.rx == '14463351405460209296167978590678323823732877767282528273954711003700640087512';
  bool sRet = signature.s == '13125281828899405792268572742549506697286726174787638372865829054711258848021';
  return rxRet && sRet;
}

Future<bool> testSignDelegation3() async {
  Uint8List sk = MinaHelper.hexToBytes('336eb4a19b3d8905824b0f2254fb495573be302c17582748bf7e101965aa4774');
  String memo = '';
  String feePayerAddress = 'B62qrKG4Z8hnzZqp1AL8WsQhQYah3quN1qUj3SyfJA8Lw135qWWg1mi';
  String senderAddress = 'B62qrKG4Z8hnzZqp1AL8WsQhQYah3quN1qUj3SyfJA8Lw135qWWg1mi';
  String receiverAddress = 'B62qicipYxyEHu7QjUqS7QvBipTs5CzgkYZZZkPoKVYBu6tnDUcE9Zt';
  BigInt fee = BigInt.from(1202056900);
  BigInt feeToken = BigInt.from(1);
  int nonce = 0;
  int validUntil = 577216;
  BigInt tokenId = BigInt.from(1);
  int tokenLocked = 0;

  Signature signature = await signDelegation(MinaHelper.reverse(sk), memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken, nonce, validUntil, tokenId, tokenLocked);
  print('--signature rx=${signature.rx}--');
  print('--signature s=${signature.s}--');
  bool rxRet = signature.rx == '17545533880613069373638190106632142626291918606826143776589947452045890400397';
  bool sRet = signature.s == '20174444549893209973127490279511354262195817219708008717243050708318889869065';
  return rxRet && sRet;
}

testGetMinaStrByNanoStr0() {
  String expected = '0.000000006';
  String calculated = MinaHelper.getMinaStrByNanoStr("6");
  bool ret = expected == calculated;
  print('testGetMinaStrByNanoStr0=$ret');
}

testGetMinaStrByNanoStr1() {
  String expected = '0.000000016';
  String calculated = MinaHelper.getMinaStrByNanoStr("16");
  bool ret = expected == calculated;
  print('testGetMinaStrByNanoStr1=$ret');
}

testGetMinaStrByNanoStr2() {
  String expected = '0.088888816';
  String calculated = MinaHelper.getMinaStrByNanoStr("88888816");
  bool ret = expected == calculated;
  print('testGetMinaStrByNanoStr2=$ret');
}

testGetMinaStrByNanoStr3() {
  String expected = '0.788888816';
  String calculated = MinaHelper.getMinaStrByNanoStr("788888816");
  bool ret = expected == calculated;
  print('testGetMinaStrByNanoStr3=$ret');
}

testGetMinaStrByNanoStr4() {
  String expected = '1.788888816';
  String calculated = MinaHelper.getMinaStrByNanoStr("1788888816");
  bool ret = expected == calculated;
  print('testGetMinaStrByNanoStr4=$ret');
}

testGetMinaStrByNanoStr5() {
  String expected = '21.788888816';
  String calculated = MinaHelper.getMinaStrByNanoStr("21788888816");
  bool ret = expected == calculated;
  print('testGetMinaStrByNanoStr5=$ret');
}

testGetMinaStrByNanoStr6() {
  String expected = '100000';
  String calculated = MinaHelper.getMinaStrByNanoStr("100000000000000");
  bool ret = expected == calculated;
  print('testGetMinaStrByNanoStr6=$ret');
}

testGetMinaStrByNanoStr7() {
  String expected = '100000.0012';
  String calculated = MinaHelper.getMinaStrByNanoStr("100000001200000");
  bool ret = expected == calculated;
  print('testGetMinaStrByNanoStr7=$ret');
}

testGetMinaStrByNanoStr8() {
  String expected = '100001';
  String calculated = MinaHelper.getMinaStrByNanoStr("100001000000000");
  bool ret = expected == calculated;
  print('testGetMinaStrByNanoStr8=$ret');
}

testGetMinaStrByNanoStr9() {
  String expected = '0.000000001';
  String calculated = MinaHelper.getMinaStrByNanoStr("00001");
  bool ret = expected == calculated;
  print('testGetMinaStrByNanoStr9=$ret');
}

testGetMinaStrByNanoStr10() {
  String expected = '0';
  String calculated = MinaHelper.getMinaStrByNanoStr("000000");
  bool ret = expected == calculated;
  print('testGetMinaStrByNanoStr10=$ret');
}

testGetMinaStrByNanoStr11() {
  String expected = '99999999999999999.999999999';
  String calculated = MinaHelper.getMinaStrByNanoStr("99999999999999999999999999");
  bool ret = expected == calculated;
  print('testGetMinaStrByNanoStr11=$ret');
}

testGetMinaStrByNanoStr12() {
  String expected = '19999999999999999.9999991';
  String calculated = MinaHelper.getMinaStrByNanoStr("0019999999999999999999999100");
  bool ret = expected == calculated;
  print('testGetMinaStrByNanoStr12=$ret');
}

testGetMinaStrByNanoStr13() {
  String expected = '19999999999999999.1';
  String calculated = MinaHelper.getMinaStrByNanoStr("0019999999999999999100000000");
  bool ret = expected == calculated;
  print('testGetMinaStrByNanoStr13=$ret');
}

testGetNanoNumByMinaStr0() {
  BigInt expected = BigInt.tryParse('10000000000123456789');
  BigInt calculated = MinaHelper.getNanoNumByMinaStr('10000000000.123456789');
  bool ret = expected == calculated;
  print('testGetNanoNumByMinaStr0: $ret');
}

testGetNanoNumByMinaStr1() {
  BigInt expected = BigInt.tryParse('10000000000123456000');
  BigInt calculated = MinaHelper.getNanoNumByMinaStr('10000000000.123456000');
  bool ret = expected == calculated;
  print('testGetNanoNumByMinaStr1: $ret');
}

testGetNanoNumByMinaStr2() {
  BigInt expected = BigInt.tryParse('10000000000000000000');
  BigInt calculated = MinaHelper.getNanoNumByMinaStr('10000000000.');
  bool ret = expected == calculated;
  print('testGetNanoNumByMinaStr2: $ret');
}

testGetNanoNumByMinaStr3() {
  BigInt expected = BigInt.tryParse('10000000000000000000');
  BigInt calculated = MinaHelper.getNanoNumByMinaStr('10000000000');
  bool ret = expected == calculated;
  print('testGetNanoNumByMinaStr3: $ret');
}

testGetNanoNumByMinaStr4() {
  BigInt expected = BigInt.tryParse('9999999999100000000');
  BigInt calculated = MinaHelper.getNanoNumByMinaStr('9999999999.1');
  bool ret = expected == calculated;
  print('testGetNanoNumByMinaStr4: $ret');
}

testGetNanoNumByMinaStr5() {
  BigInt expected = BigInt.tryParse('1234500000');
  BigInt calculated = MinaHelper.getNanoNumByMinaStr('1.2345');
  bool ret = expected == calculated;
  print('testGetNanoNumByMinaStr5: $ret');
}

testGetNanoNumByMinaStr6() {
  BigInt expected = BigInt.tryParse('60000');
  BigInt calculated = MinaHelper.getNanoNumByMinaStr('0.00006');
  bool ret = expected == calculated;
  print('testGetNanoNumByMinaStr6: $ret');
}

testGetNanoNumByMinaStr7() {
  BigInt expected = BigInt.tryParse('6');
  BigInt calculated = MinaHelper.getNanoNumByMinaStr('0.000000006');
  bool ret = expected == calculated;
  print('testGetNanoNumByMinaStr7: $ret');
}

testGetNanoNumByMinaStr8() {
  BigInt expected = BigInt.tryParse('6');
  BigInt calculated = MinaHelper.getNanoNumByMinaStr('.000000006');
  bool ret = expected == calculated;
  print('testGetNanoNumByMinaStr8: $ret');
}

testGetNanoNumByMinaStr9() {
  BigInt expected = BigInt.tryParse('6000000000');
  BigInt calculated = MinaHelper.getNanoNumByMinaStr('0000006');
  bool ret = expected == calculated;
  print('testGetNanoNumByMinaStr9: $ret');
}

testGetNanoNumByMinaStr10() {
  BigInt expected = BigInt.tryParse('6000000000');
  BigInt calculated = MinaHelper.getNanoNumByMinaStr('0000006.00');
  bool ret = expected == calculated;
  print('testGetNanoNumByMinaStr10: $ret');
}

testGetNanoNumByMinaStr11() {
  BigInt expected = BigInt.tryParse('110000000');
  BigInt calculated = MinaHelper.getNanoNumByMinaStr('00.110');
  bool ret = expected == calculated;
  print('testGetNanoNumByMinaStr11: $ret');
}
