import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ffi_mina_signer/sdk/ffi_mina_signer.dart';

void main() {
  const MethodChannel channel = MethodChannel('ffi_mina_signer');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FfiMinaSigner.platformVersion, '42');
  });
}
