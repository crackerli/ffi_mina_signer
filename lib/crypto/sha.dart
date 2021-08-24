import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';

/// Password hashing has moved to Argon2id(v13).
/// This was only for the old users who has his data encrypted by old method.
/// Any new users would discard this method.
@deprecated
class Sha {
  /// Calculates the sha256 hash from the given buffers.
  ///
  /// @param {List<Uint8List>} byte arrays
  /// @returns {Uint8List}
  @deprecated
  static Uint8List sha256(List<Uint8List> byteArrays) {
    Digest digest = Digest("SHA-256");
    Uint8List hashed = Uint8List(32);
    byteArrays.forEach((byteArray) {
      digest.update(byteArray, 0, byteArray.lengthInBytes);
    });
    digest.doFinal(hashed, 0);
    return hashed;
  }

  /// Calculates the sha512 hash from the given buffers.
  ///
  /// @param {List<Uint8List>} byte arrays
  /// @returns {Uint8List}
  @deprecated
  static Uint8List sha512(List<Uint8List> byteArrays) {
    Digest digest = Digest("SHA-512");
    Uint8List hashed = Uint8List(64);
    byteArrays.forEach((byteArray) {
      digest.update(byteArray, 0, byteArray.lengthInBytes);
    });
    digest.doFinal(hashed, 0);

    return hashed;
  }
}
