import 'dart:typed_data';

import 'package:ffi_mina_signer/crypto/sha.dart';
import 'package:ffi_mina_signer/encrypt/kdf/kdf.dart';
import 'package:ffi_mina_signer/encrypt/model/keyiv.dart';
import 'package:ffi_mina_signer/util/mina_helper.dart';

/// Sha256 Key Derivation Function
/// It's not very anti-brute forceable, but it's fast which is an important feature
/// Anti-brute forceable is a lower priority than speed, because key security is on the individual user
/// there's no centralized database of key
class Sha256KDF extends KDF {
  /// Gets the key and iv
  KeyIV deriveKey(String password, {Uint8List? salt}) {
    Uint8List pwBytes = MinaHelper.stringToBytesUtf8(password);
    Uint8List saltBytes = salt == null ? Uint8List(1) : salt;

    // Key = sha256 (password + salt);
    Uint8List key = Sha.sha256([pwBytes, saltBytes]);
    // iv = sha256 (KEY + password + salt);
    Uint8List iv = Sha.sha256([key, pwBytes, saltBytes]).sublist(0, 16);

    return KeyIV(key, iv);
  }
}
