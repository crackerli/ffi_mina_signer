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
    return Uint8List.fromList(utf8.encode(str));
  }

  /// Convert byte array to string utf-8
  static String bytesToUtf8String(Uint8List bytes) {
    return utf8.decode(bytes);
  }

  // Copy byte array to native heap
  static Pointer<Uint8> copyBytesToPointer(Uint8List bytes) {
    final length = bytes.lengthInBytes;
    final result = calloc<Uint8>(length);

    for (var i = 0; i < length; ++i) {
      result[i] = bytes[i];
    }

    return result;
  }

  // Copy string to native heap, add ending 0 for C
  static Pointer<Uint8> copyStringToPointer(Uint8List bytes) {
    final length = bytes.lengthInBytes;
    final result = calloc<Uint8>(length + 1);

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

  static Uint8List uint64ToBytes(BigInt bigInt) {
    return hexToBytes(bigInt.toRadixString(16).padLeft(16, "0"));
  }

  static BigInt? _fractionsToNanoMina(String fractions) {
    BigInt? tmp = BigInt.tryParse(fractions);
    if(fractions.length < 9) {
      int padding = 9 - fractions.length;
      BigInt base = BigInt.from(10).pow(padding);
      return (tmp! * base);
    }
    return tmp;
  }

  static String getMinaStrByNanoNum(BigInt? number) {
    if(null == number) {
      return '';
    }

    if(BigInt.from(0) == number) {
      return '0';
    }

    BigInt intPart = number ~/ BigInt.from(1000000000);
    BigInt fractionPart = number - (intPart * BigInt.from(1000000000));
    if(fractionPart == BigInt.from(0)) {
      return '$intPart';
    }

    // Remove tailed zeros of fractions part
    String fractionStr = fractionPart.toString().padLeft(9, '0');
    int zeroIndex = fractionStr.length - 1;
    for(; zeroIndex >= 0; zeroIndex--) {
      if(fractionStr[zeroIndex] != '0') {
        break;
      }
    }

    String trimmedFractionStr = fractionStr.substring(0, zeroIndex + 1);

    return '$intPart.$trimmedFractionStr';
  }

  static String getMinaStrByNanoStr(String? src) {
    if(null == src || src.isEmpty) {
      return '';
    }

    BigInt? number = BigInt.tryParse(src);
    return getMinaStrByNanoNum(number);
  }

  static String getNanoStrByMinaStr(String src) {
    return getNanoNumByMinaStr(src).toString();
  }

  static BigInt? getNanoNumByMinaStr(String? src) {
    if(null == src || src.isEmpty) {
      return BigInt.from(0);
    }

    // src is a integer
    if(!src.contains('.')) {
      return (BigInt.tryParse(src)! * BigInt.from(1000000000));
    }

    int dotIndex = src.indexOf('.');
    // if src is a integer, and . at the end
    if(dotIndex == src.length - 1) {
      return (BigInt.tryParse(src.substring(0, src.length - 1))! * BigInt.from(1000000000));
    }

    if(dotIndex == 0) {
      String fractions = src.substring(1, src.length);
      return _fractionsToNanoMina(fractions);
    }

    String intStr = src.substring(0, dotIndex);
    String fractionStr = src.substring(dotIndex + 1, src.length);
    BigInt intPart = BigInt.tryParse(intStr)! * BigInt.from(1000000000);
    BigInt? fractionPart = _fractionsToNanoMina(fractionStr);
    return intPart + fractionPart!;
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