import 'dart:math';
import 'dart:typed_data';

import 'package:ffi_mina_signer/encrypt/aes/aes_cbcpkcs7.dart';
import 'package:ffi_mina_signer/encrypt/kdf/argon2_kdf.dart';
import 'package:ffi_mina_signer/encrypt/kdf/kdf.dart';
import 'package:ffi_mina_signer/encrypt/kdf/sha256_kdf.dart';
import 'package:ffi_mina_signer/encrypt/model/keyiv.dart';
import 'package:ffi_mina_signer/util/mina_helper.dart';
import 'package:flutter_sodium/flutter_sodium.dart';

const SODIUM_PREFIX = 'Sodium__';

const XCHACHA20_ADDITIONAL_DATA = 'StakingPower';

// Temp class for Dart compute usage
class CipherSource {
  late String password;
  late Uint8List source;
  bool? sodium;
}

/// Utility for encrypting and decrypting
class MinaCryptor {

  /// Decrypts a value with a password using AES/CBC/PKCS7
  /// KDF is Sha256KDF if not specified
  static Future<Uint8List> decrypt(dynamic value, String password, {KDF? kdf}) async {
    kdf = kdf ?? Sha256KDF();
    Uint8List valBytes;
    if (value is String) {
      valBytes = MinaHelper.hexToBytes(value);
    } else if (value is Uint8List) {
      valBytes = value;
    } else {
      throw Exception('Value should be a string or a byte array');
    }

    // Get prefix tag to determine how to choose decrypt method.
    Uint8List prefix = valBytes.sublist(0, 8);
    if(MinaHelper.bytesToUtf8String(prefix) == SODIUM_PREFIX) {
      return await _decryptXChaCha(valBytes, password);
    }

    Uint8List salt = valBytes.sublist(8, 16);
    KeyIV key = kdf.deriveKey(password, salt: salt);

    // Decrypt
    Uint8List encData = valBytes.sublist(16);

    return AesCbcPkcs7.decrypt(encData, key: key.key, iv: key.iv);
  }

  /// Encrypts a value using AES/CBC/PKCS7
  /// KDF is Sha256KDF if not specified
  static Future<Uint8List> encrypt(dynamic value, String password, bool sodium, {KDF? kdf}) async {
    kdf = kdf ?? Sha256KDF();
    Uint8List valBytes;
    if (value is String) {
      valBytes = MinaHelper.hexToBytes(value);
    } else if (value is Uint8List) {
      valBytes = value;
    } else {
      throw Exception('Seed should be a string or uint8list');
    }

    if(sodium) {
      return await _encryptXChaCha(valBytes, password);
    }

    // Generate a random salt
    Uint8List salt = Uint8List(8);
    Random rng = Random.secure();
    for (int i = 0; i < 8; i++) {
      salt[i] = rng.nextInt(255);
    }

    KeyIV keyInfo = kdf.deriveKey(password, salt: salt);

    Uint8List seedEncrypted =
        AesCbcPkcs7.encrypt(valBytes, key: keyInfo.key, iv: keyInfo.iv);

    return MinaHelper.concat(
        [MinaHelper.stringToBytesUtf8("Salted__"), salt, seedEncrypted]);
  }

  /// Encrypts a value using XChaCha20Poly1305Ietf with attached mode
  /// KDF is Argon2id
  static Future<Uint8List> _encryptXChaCha(Uint8List bytes, String password) async {
    // Generate a salt with 128 bits
    final salt = PasswordHash.randomSalt();
    Uint8List key = await Argon2KDF.deriveKey(password, salt);

    // Generate a nonce with 192 bits
    final nonce = XChaCha20Poly1305Ietf.randomNonce();
    final additionalData = MinaHelper.stringToBytesUtf8("StakingPower");
    // encrypt
    final cipherContent =
      XChaCha20Poly1305Ietf.encrypt(bytes, nonce, key, additionalData: additionalData);
    return MinaHelper.concat(
      [MinaHelper.stringToBytesUtf8(SODIUM_PREFIX), salt, nonce, cipherContent]);
  }

  static Future<Uint8List> _decryptXChaCha(Uint8List bytes, String password) async {
    final Uint8List salt = bytes.sublist(8, 24);
    final Uint8List nonce = bytes.sublist(24, 48);
    final Uint8List cipherContent = bytes.sublist(48);

    Uint8List key = await Argon2KDF.deriveKey(password, salt);

    final additionalData = MinaHelper.stringToBytesUtf8("StakingPower");
    // decrypt
    final plainContent = XChaCha20Poly1305Ietf.decrypt(
      cipherContent, nonce, key,
      additionalData: additionalData);

    return plainContent;
  }
}
