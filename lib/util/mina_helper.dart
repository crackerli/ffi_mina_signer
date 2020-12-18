import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:hex/hex.dart';

class MinaHelper {
  /// Decode a BigInt from bytes in big-endian encoding.
  static BigInt _decodeBigInt(List<int> bytes) {
    BigInt result = BigInt.from(0);
    for (int i = 0; i < bytes.length; i++) {
      result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
    }
    return result;
  }

  static BigInt byteToBigInt(Uint8List bigIntBytes) {
    return _decodeBigInt(bigIntBytes);
  }

  /// Convert string to byte array
  static Uint8List stringToBytesUtf8(String str) {
    return utf8.encode(str);
  }

  /// Convert byte array to string utf-8
  static String bytesToUtf8String(Uint8List bytes) {
    return utf8.decode(bytes);
  }

  // Copy byte array to native heap
  static Pointer<Uint8> copyBytesToPointer(Uint8List bytes) {
    final length = bytes.lengthInBytes;
    final result = allocate<Uint8>(count: length);

    for (var i = 0; i < length; ++i) {
      result[i] = bytes[i];
    }

    return result;
  }

  // Copy string to native heap, add ending 0 for C
  static Pointer<Uint8> copyStringToPointer(Uint8List bytes) {
    final length = bytes.lengthInBytes;
    final result = allocate<Uint8>(count: length + 1);

    for (var i = 0; i < length; ++i) {
      result[i] = bytes[i];
    }
    result[length] = 0;

    return result;
  }

  static Uint8List reverse(Uint8List bytes) {
    Uint8List reversed = Uint8List(bytes.length);
    for (int i = bytes.length; i > 0; i--) {
      reversed[bytes.length - i] = bytes[i - 1];
    }
    return reversed;
  }

  /// Converts a hex string to a Uint8List
  static Uint8List hexToBytes(String hex) {
    return Uint8List.fromList(HEX.decode(hex));
  }

  /// Converts a Uint8List to a hex string
  static String byteToHex(Uint8List bytes) {
    return HEX.encode(bytes).toUpperCase();
  }

  /// Convert a bigint to a byte array
  static Uint8List bigIntToBytes(BigInt bigInt) {
    return hexToBytes(bigInt.toRadixString(16).padLeft(32, "0"));
  }

  /// Concatenates one or more byte arrays
  ///
  /// @param {List<Uint8List>} bytes
  /// @returns {Uint8List}
  static Uint8List concat(List<Uint8List> bytes) {
    String hex = '';
    bytes.forEach((v) {
      hex += byteToHex(v);
    });
    return hexToBytes(hex);
  }
}