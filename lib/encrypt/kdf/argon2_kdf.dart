import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_sodium/flutter_sodium.dart';

const ARGON2_OPS_LIMIT = 3;
const ARGON2_MEM_LIMIT = 128 * 1024 * 1024;
const ARGON2_OUT_LEN = 32;

class Argon2Params {
  String password;
  Uint8List salt;
  int opsLimit;
  int memLimit;
  int outLen;

  Argon2Params(this.password, this.salt, this.opsLimit, this.memLimit, this.outLen);
}

class Argon2KDF {
  static Future<Uint8List> deriveKey(String password, Uint8List salt) async {
    Argon2Params params = Argon2Params(password, salt, ARGON2_OPS_LIMIT, ARGON2_MEM_LIMIT, ARGON2_OUT_LEN);
    print('Start argon2 password hash');
    return await compute(passwordHash, params);
  }

  static Uint8List passwordHash(Argon2Params params) {
    var derivedKey = PasswordHash.hashString(params.password, params.salt,
        opslimit: params.opsLimit, memlimit: params.memLimit, outlen: params.outLen);
    return derivedKey;
  }
}