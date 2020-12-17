import 'package:pointycastle/digests/sha256.dart';

// Global sha256 digest from pointy castle
final gSHA256Digest = SHA256Digest();

/// Used for the Base58 encoding.
const String gBase58Alphabet =
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';