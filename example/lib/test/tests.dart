import 'dart:convert';
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

void testSignTransaction() {
  Uint8List sk = Uint8List(32);
  sk[0]  = 0xe3; sk[1]  = 0xf6; sk[2]  = 0x23; sk[3]  = 0xd9; sk[4]  = 0xee; sk[5]  = 0xd6; sk[6]  = 0x14; sk[7]  = 0xca;
  sk[8]  = 0xb2; sk[9]  = 0xe6; sk[10] = 0x29; sk[11] = 0x5e; sk[12] = 0x1b; sk[13] = 0x5a; sk[14] = 0x18; sk[15] = 0x61;
  sk[16] = 0x3b; sk[17] = 0x75; sk[18] = 0x30; sk[19] = 0x9c; sk[20] = 0xde; sk[21] = 0x38; sk[22] = 0x6d; sk[23] = 0xe2;
  sk[24] = 0x14; sk[25] = 0x57; sk[26] = 0x0a; sk[27] = 0xfb; sk[28] = 0x0e; sk[29] = 0xdf; sk[30] = 0x3f; sk[31] = 0x00;
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
  int tokenLocked = 0;

  Signature signature = signTransaction(sk, memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken, nonce, validUntil, tokenId, amount, tokenLocked);
  print('---------------------- signature rx=${signature.rx} ------------------');
  print('---------------------- signature s=${signature.s} ------------------');
}

void testSignDelegation() {
  Uint8List sk = Uint8List(32);
  sk[0]  = 0xe3; sk[1]  = 0xf6; sk[2]  = 0x23; sk[3]  = 0xd9; sk[4]  = 0xee; sk[5]  = 0xd6; sk[6]  = 0x14; sk[7]  = 0xca;
  sk[8]  = 0xb2; sk[9]  = 0xe6; sk[10] = 0x29; sk[11] = 0x5e; sk[12] = 0x1b; sk[13] = 0x5a; sk[14] = 0x18; sk[15] = 0x61;
  sk[16] = 0x3b; sk[17] = 0x75; sk[18] = 0x30; sk[19] = 0x9c; sk[20] = 0xde; sk[21] = 0x38; sk[22] = 0x6d; sk[23] = 0xe2;
  sk[24] = 0x14; sk[25] = 0x57; sk[26] = 0x0a; sk[27] = 0xfb; sk[28] = 0x0e; sk[29] = 0xdf; sk[30] = 0x3f; sk[31] = 0x00;
  String memo = 'more delegates, more fun';
  String feePayerAddress = 'B62qiy32p8kAKnny8ZFwoMhYpBppM1DWVCqAPBYNcXnsAHhnfAAuXgg';
  String senderAddress = 'B62qiy32p8kAKnny8ZFwoMhYpBppM1DWVCqAPBYNcXnsAHhnfAAuXgg';
  String receiverAddress = 'B62qkfHpLpELqpMK6ZvUTJ5wRqKDRF3UHyJ4Kv3FU79Sgs4qpBnx5RR';
  int fee = 3;
  int feeToken = 1;
  int nonce = 10;
  int validUntil = 4000;
  int tokenId = 1;
  int tokenLocked = 0;

  Signature signature = signDelegation(sk, memo, feePayerAddress, senderAddress,
      receiverAddress, fee, feeToken, nonce, validUntil, tokenId, tokenLocked);

  print('---------------------- signature rx=${signature.rx} ------------------');
  print('---------------------- signature s=${signature.s} ------------------');
}

void testBIP44() async {
  var mnemonic = bip39.generateMnemonic();
  print('---------------- $mnemonic ----------------------');
  String seed = bip39.mnemonicToSeedHex(mnemonic);
  Uint8List seed1 = bip39.mnemonicToSeed(mnemonic);
  Uint8List seedBytes = MinaHelper.hexToBytes(seed);
//   m / purpose' / coin_type' / account' / change / address_index
  Chain chain = Chain.seed(hex.encode(MinaHelper.hexToBytes(seed)));
  Chain chain1 = Chain.seed(hex.encode(seed1));
  ExtendedPrivateKey key = chain.forPath("m/44'/12586'/0'/0/0");
  ExtendedPrivateKey key10 = chain.forPath("m/44'/12586'/0'/0/0");
  ExtendedPrivateKey key1 = chain1.forPath("m/44'/12586'/0'/0/0");

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

/// Result public key should be: B62qrGaXh9wekfwaA2yzUbhbvFYynkmBkhYLV36dvy5AkRvgeQnY6vx
bool testAccount0BitInteger() {
  BigInt sk = BigInt.parse('27145950286090989573235160126994188021722699404890955797699008383743072908774');
  Uint8List skList = MinaHelper.bigIntToBytes(sk);

  String address = getAddressFromSecretKey(MinaHelper.reverse(skList));
  bool testRet = 'B62qrGaXh9wekfwaA2yzUbhbvFYynkmBkhYLV36dvy5AkRvgeQnY6vx' == address;
  print('=================== testAccount0BitInteger passed: $testRet ================');
  return testRet;
}

/// Result public key should be: B62qrGaXh9wekfwaA2yzUbhbvFYynkmBkhYLV36dvy5AkRvgeQnY6vx
bool testAccount0BE() {
  Uint8List sk = MinaHelper.hexToBytes('3c041039ac9ac5dea94330115aacf6d4780f08d7299a84a6ee2b62599cebb5e6');
  String address = getAddressFromSecretKey(MinaHelper.reverse(sk));
  bool testRet = 'B62qrGaXh9wekfwaA2yzUbhbvFYynkmBkhYLV36dvy5AkRvgeQnY6vx' == address;
  print('=================== testAccount0BE passed: $testRet ================');
  return testRet;
}

/// Result public key should be: B62qpaDc8nfu4a7xghkEni8u2rBjx7EH95MFeZAhTgGofopaxFjdS7P
bool testAccount1BE() {
  Uint8List sk = MinaHelper.hexToBytes('06270f74f8a6f2529f492a3bf112a3806e91e62b8fc3f247569e9a43ba9e8d6e');
  String address = getAddressFromSecretKey(MinaHelper.reverse(sk));
  bool testRet = 'B62qpaDc8nfu4a7xghkEni8u2rBjx7EH95MFeZAhTgGofopaxFjdS7P' == address;
  print('=================== testAccount1BE passed: $testRet ================');
  return testRet;
}

/// Result public key should be: B62qpkf1jH9sqtZy4kAJHgdChfuRX7SPqoX4Q2ZjJH2YDNWUUd92bxo
bool testAccount2BE() {
  Uint8List sk = MinaHelper.hexToBytes('2943fbbbcf63025456cfcebae3f481462b1e720d0c7d2a10d113fb6b1847cb3d');
  String address = getAddressFromSecretKey(MinaHelper.reverse(sk));
  bool testRet = 'B62qpkf1jH9sqtZy4kAJHgdChfuRX7SPqoX4Q2ZjJH2YDNWUUd92bxo' == address;
  print('=================== testAccount2BE passed: $testRet ================');
  return testRet;
}

/// Result public key should be: B62qnpUj6EJGNvhJFMEAmM6skJRg1H37hVsHvPHMXhHeCXfKhSWGkGN
bool testAccount3BE() {
  Uint8List sk = MinaHelper.hexToBytes('03e97cbf15dba6da23616785886f8cb4ce9ced51f0140261332ee063bb7f17d3');
  String address = getAddressFromSecretKey(MinaHelper.reverse(sk));
  bool testRet = 'B62qnpUj6EJGNvhJFMEAmM6skJRg1H37hVsHvPHMXhHeCXfKhSWGkGN' == address;
  print('=================== testAccount3BE passed: $testRet ================');
  return testRet;
}

/// Result public key should be: B62qq8DZP9h5cCKr6ecXY3MqVz1oQuEzJMyZLCbEukCJGS9SuVXK33o
bool testAccount49370BE() {
  Uint8List sk = MinaHelper.hexToBytes('02989a314a65930de289a5578daa03c3410b177e009121574d8730bf8644ab9f');
  String address = getAddressFromSecretKey(MinaHelper.reverse(sk));
  bool testRet = 'B62qq8DZP9h5cCKr6ecXY3MqVz1oQuEzJMyZLCbEukCJGS9SuVXK33o' == address;
  print('=================== testAccount49370BE passed: $testRet ================');
  return testRet;
}

/// Result public key should be: B62qnWKWnUmj3mxUx4UcnQGMMsqwNkHUdgzvhto6Je3LwKSRb7dYqm9
bool testAccount12586BE() {
  Uint8List sk = MinaHelper.hexToBytes('1f2c90f146d1035280364cb1a01a89e7586a340972936abd5d72307a0674549c');
  String address = getAddressFromSecretKey(MinaHelper.reverse(sk));
  bool testRet = 'B62qnWKWnUmj3mxUx4UcnQGMMsqwNkHUdgzvhto6Je3LwKSRb7dYqm9' == address;
  print('=================== testAccount12586BE passed: $testRet ================');
  return testRet;
}

bool testSignTransaction0() {
  Uint8List sk = MinaHelper.hexToBytes('3c041039ac9ac5dea94330115aacf6d4780f08d7299a84a6ee2b62599cebb5e6');
  String memo = 'Hello Mina!';
  String feePayerAddress = 'B62qrGaXh9wekfwaA2yzUbhbvFYynkmBkhYLV36dvy5AkRvgeQnY6vx';
  String senderAddress = 'B62qrGaXh9wekfwaA2yzUbhbvFYynkmBkhYLV36dvy5AkRvgeQnY6vx';
  String receiverAddress = 'B62qpaDc8nfu4a7xghkEni8u2rBjx7EH95MFeZAhTgGofopaxFjdS7P';
  int fee = 2000000000;
  int feeToken = 1;
  int nonce = 16;
  int validUntil = 271828;
  int tokenId = 1;
  int amount = 1729000000000;
  int tokenLocked = 0;

  Signature signature = signTransaction(MinaHelper.reverse(sk), memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken, nonce, validUntil, tokenId, amount, tokenLocked);
  print('--signature rx=${signature.rx}--');
  print('--signature s=${signature.s}--');
  bool rxRet = signature.rx == '18802239217567102461146151326321470153125473800409355550698278752629088915951';
  bool sRet = signature.s == '13798361838923054224304549511625686598426485059736277382115852538612284809426';
  return rxRet && sRet;
}

bool testSignTransaction1() {
  Uint8List sk = MinaHelper.hexToBytes('1f2c90f146d1035280364cb1a01a89e7586a340972936abd5d72307a0674549c');
  String memo = '';
  String feePayerAddress = 'B62qnWKWnUmj3mxUx4UcnQGMMsqwNkHUdgzvhto6Je3LwKSRb7dYqm9';
  String senderAddress = 'B62qnWKWnUmj3mxUx4UcnQGMMsqwNkHUdgzvhto6Je3LwKSRb7dYqm9';
  String receiverAddress = 'B62qpkf1jH9sqtZy4kAJHgdChfuRX7SPqoX4Q2ZjJH2YDNWUUd92bxo';
  int fee = 1618033988;
  int feeToken = 1;
  int nonce = 0;
  int validUntil = 4294967295;
  int tokenId = 1;
  int amount = 314159265359;
  int tokenLocked = 0;

  Signature signature = signTransaction(MinaHelper.reverse(sk), memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken, nonce, validUntil, tokenId, amount, tokenLocked);
  print('--signature rx=${signature.rx}--');
  print('--signature s=${signature.s}--');
  bool rxRet = signature.rx == '27868897936794982770752119679041533974967348280365384398744708741877580834675';
  bool sRet = signature.s == '23548656286909298036252341845310377058595185877124773386777818829122223941592';
  return rxRet && sRet;
}

bool testSignTransaction2() {
  Uint8List sk = MinaHelper.hexToBytes('1f2c90f146d1035280364cb1a01a89e7586a340972936abd5d72307a0674549c');
  String memo = '01234567890123456789012345678901';
  String feePayerAddress = 'B62qnWKWnUmj3mxUx4UcnQGMMsqwNkHUdgzvhto6Je3LwKSRb7dYqm9';
  String senderAddress = 'B62qnWKWnUmj3mxUx4UcnQGMMsqwNkHUdgzvhto6Je3LwKSRb7dYqm9';
  String receiverAddress = 'B62qnpUj6EJGNvhJFMEAmM6skJRg1H37hVsHvPHMXhHeCXfKhSWGkGN';
  int fee = 100000;
  int feeToken = 1;
  int nonce = 5687;
  int validUntil = 4294967295;
  int tokenId = 1;
  int amount = 271828182845904;
  int tokenLocked = 0;

  Signature signature = signTransaction(MinaHelper.reverse(sk), memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken, nonce, validUntil, tokenId, amount, tokenLocked);
  print('--signature rx=${signature.rx}--');
  print('--signature s=${signature.s}--');
  bool rxRet = signature.rx == '12054183831657951388057813431405760147487230601297876260078219044504236834409';
  bool sRet = signature.s == '5699529145697995178905015194447388739220537023905547723218090337241275344580';
  return rxRet && sRet;
}

void testSignDelegation1() {
  Uint8List sk = MinaHelper.hexToBytes('2943fbbbcf63025456cfcebae3f481462b1e720d0c7d2a10d113fb6b1847cb3d');
  String memo = '';
  String feePayerAddress = 'B62qpkf1jH9sqtZy4kAJHgdChfuRX7SPqoX4Q2ZjJH2YDNWUUd92bxo';
  String senderAddress = 'B62qpkf1jH9sqtZy4kAJHgdChfuRX7SPqoX4Q2ZjJH2YDNWUUd92bxo';
  String receiverAddress = 'B62qpaDc8nfu4a7xghkEni8u2rBjx7EH95MFeZAhTgGofopaxFjdS7P';
  int fee = 1202056900;
  int feeToken = 1;
  int nonce = 0;
  int validUntil = 577216;
  int tokenId = 1;
  int amount = 0;
  int tokenLocked = 0;

  Signature signature = signDelegation(MinaHelper.reverse(sk), memo, feePayerAddress,
      senderAddress, receiverAddress, fee, feeToken, nonce, validUntil, tokenId, tokenLocked);
  print('--signature rx=${signature.rx}--');
  print('--signature s=${signature.s}--');
}