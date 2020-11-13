
import 'dart:async';

import 'package:flutter/services.dart';

class FfiMinaSigner {
  static const MethodChannel _channel =
      const MethodChannel('ffi_mina_signer');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
