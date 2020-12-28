import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ffi_mina_signer/sdk/ffi_mina_signer.dart';
import 'package:flutter/services.dart';
import 'test/tests.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
//    testSignDelegation1();
//    initPlatformState();
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
          title: const Text('Mina Signer example app'),
        ),
        body: Column(
          children: [
            Text('testAccount0BigInteger passed: ${testAccount0BitInteger()}'),
            Text('testAccount0BE passed: ${testAccount0BE()}'),
            Text('testAccount1BE passed: ${testAccount1BE()}'),
            Text('testAccount2BE passed: ${testAccount2BE()}'),
            Text('testAccount49370BE passed: ${testAccount49370BE()}'),
            Text('testAccount12586BE passed: ${testAccount12586BE()}'),
            Text('testSignTransaction0 passed: ${testSignTransaction0()}'),
            Text('testSignTransaction1 passed: ${testSignTransaction1()}'),
            Text('testSignTransaction2 passed: ${testSignTransaction2()}'),
          ],
        )
      ),
    );
  }
}
