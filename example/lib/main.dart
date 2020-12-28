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

  @override
  void initState() {
    super.initState();
    testSignPayment0Async();
    testSignPayment1Async();
    testSignPayment2Async();
    testSignPayment3Async();
    testSignDelegation0Async();
    testSignDelegation1Async();
    testSignDelegation2Async();
    testSignDelegation3Async();
  }
  
  bool _testSignPayment0Ret = false;
  Future<void> testSignPayment0Async() async {
    bool testSignPayment0Ret = await testSignPayment0();
    if (!mounted) return;
    setState(() {
      _testSignPayment0Ret = testSignPayment0Ret;
    });
  }

  bool _testSignPayment1Ret = false;
  Future<void> testSignPayment1Async() async {
    bool testSignPayment1Ret = await testSignPayment1();
    if (!mounted) return;
    setState(() {
      _testSignPayment1Ret = testSignPayment1Ret;
    });
  }

  bool _testSignPayment2Ret = false;
  Future<void> testSignPayment2Async() async {
    bool testSignPayment2Ret = await testSignPayment2();
    if (!mounted) return;
    setState(() {
      _testSignPayment2Ret = testSignPayment2Ret;
    });
  }

  bool _testSignPayment3Ret = false;
  Future<void> testSignPayment3Async() async {
    bool testSignPayment3Ret = await testSignPayment3();
    if (!mounted) return;
    setState(() {
      _testSignPayment3Ret = testSignPayment3Ret;
    });
  }

  bool _testSignDelegation0Ret = false;
  Future<void> testSignDelegation0Async() async {
    bool testSignDelegation0Ret = await testSignDelegation0();
    if (!mounted) return;
    setState(() {
      _testSignDelegation0Ret = testSignDelegation0Ret;
    });
  }

  bool _testSignDelegation1Ret = false;
  Future<void> testSignDelegation1Async() async {
    bool testSignDelegation1Ret = await testSignDelegation1();
    if (!mounted) return;
    setState(() {
      _testSignDelegation1Ret = testSignDelegation1Ret;
    });
  }

  bool _testSignDelegation2Ret = false;
  Future<void> testSignDelegation2Async() async {
    bool testSignDelegation2Ret = await testSignDelegation2();
    if (!mounted) return;
    setState(() {
      _testSignDelegation2Ret = testSignDelegation2Ret;
    });
  }

  bool _testSignDelegation3Ret = false;
  Future<void> testSignDelegation3Async() async {
    bool testSignDelegation3Ret = await testSignDelegation3();
    if (!mounted) return;
    setState(() {
      _testSignDelegation3Ret = testSignDelegation3Ret;
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
            Text('testAccount0 passed: ${testAccount0()}'),
            Text('testAccount1 passed: ${testAccount1()}'),
            Text('testAccount2BE passed: ${testAccount2()}'),
            Text('testAccount49370BE passed: ${testAccount49370()}'),
            Text('testAccount12586BE passed: ${testAccount12586()}'),
            Text('testSignPayment0 passed: $_testSignPayment0Ret'),
            Text('testSignPayment1 passed: $_testSignPayment1Ret'),
            Text('testSignPayment2 passed: $_testSignPayment2Ret'),
            Text('testSignPayment3 passed: $_testSignPayment3Ret'),
            Text('testSignDelegation0 passed: $_testSignDelegation0Ret'),
            Text('testSignDelegation1 passed: $_testSignDelegation1Ret'),
            Text('testSignDelegation2 passed: $_testSignDelegation2Ret'),
            Text('testSignDelegation3 passed: $_testSignDelegation3Ret'),
          ],
        )
      ),
    );
  }
}
