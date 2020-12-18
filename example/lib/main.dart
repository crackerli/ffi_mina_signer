import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ffi_mina_signer/sdk/ffi_mina_signer.dart';
import 'package:flutter/services.dart';
import 'package:ffi_mina_signer/tests/tests.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

// Scalar priv_key = { 0xca14d6eed923f6e3, 0x61185a1b5e29e6b2, 0xe26d38de9c30753b, 0x3fdf0efb0a5714 };

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
//    nativeSignDelegation();
//   String address = getAddress();
//   print('================= $address =======================');
//    testBase58Enc();
//    testInvalidBase58Enc();
//    signUserCommand();
//    testUint64();
//    testGetAddressFromSecretKey();
//    testSignTransaction();
//    testSignDelegation();
    testBIP44();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FfiMinaSigner.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
