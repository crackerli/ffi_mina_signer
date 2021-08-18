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
//    testSignTransaction();
    testAccount0Async();
    testAccount1Async();
    testAccount2Async();
    testAccount3Async();
    testAccount49370Async();
    testAccount12586Async();
    testSignPayment0Async();
    testSignPayment1Async();
    testSignPayment2Async();
    testSignPayment3Async();
    testSignDelegation0Async();
    testSignDelegation1Async();
    testSignDelegation2Async();
    testSignDelegation3Async();
    testGetMinaStrByNanoStr0();
    testGetMinaStrByNanoStr1();
    testGetMinaStrByNanoStr2();
    testGetMinaStrByNanoStr3();
    testGetMinaStrByNanoStr4();
    testGetMinaStrByNanoStr5();
    testGetMinaStrByNanoStr6();
    testGetMinaStrByNanoStr7();
    testGetMinaStrByNanoStr8();
    testGetMinaStrByNanoStr9();
    testGetMinaStrByNanoStr9();
    testGetMinaStrByNanoStr10();
    testGetMinaStrByNanoStr11();
    testGetMinaStrByNanoStr12();
    testGetMinaStrByNanoStr13();
    testGetNanoNumByMinaStr0();
    testGetNanoNumByMinaStr1();
    testGetNanoNumByMinaStr2();
    testGetNanoNumByMinaStr3();
    testGetNanoNumByMinaStr4();
    testGetNanoNumByMinaStr5();
    testGetNanoNumByMinaStr6();
    testGetNanoNumByMinaStr7();
    testGetNanoNumByMinaStr8();
    testGetNanoNumByMinaStr9();
    testGetNanoNumByMinaStr10();
    testGetNanoNumByMinaStr11();

    mainSignPayment0Async();
    mainSignPayment1Async();
    mainSignPayment2Async();
    mainSignPayment3Async();
    mainSignDelegation0Async();
    mainSignDelegation1Async();
    mainSignDelegation2Async();
    mainSignDelegation3Async();
    testSodium();
    testPointyCastle();
  }

  bool _testAccount0Ret = false;
  Future<void> testAccount0Async() async {
    bool testAccount0Ret = await testAccount0();
    if (!mounted) return;
    setState(() {
      _testAccount0Ret = testAccount0Ret;
    });
  }

  bool _testAccount1Ret = false;
  Future<void> testAccount1Async() async {
    bool testAccount1Ret = await testAccount1();
    if (!mounted) return;
    setState(() {
      _testAccount1Ret = testAccount1Ret;
    });
  }

  bool _testAccount2Ret = false;
  Future<void> testAccount2Async() async {
    bool testAccount2Ret = await testAccount2();
    if (!mounted) return;
    setState(() {
      _testAccount2Ret = testAccount2Ret;
    });
  }

  bool _testAccount3Ret = false;
  Future<void> testAccount3Async() async {
    bool testAccount3Ret = await testAccount3();
    if (!mounted) return;
    setState(() {
      _testAccount3Ret = testAccount3Ret;
    });
  }

  bool _testAccount49370Ret = false;
  Future<void> testAccount49370Async() async {
    bool testAccount49370Ret = await testAccount49370();
    if (!mounted) return;
    setState(() {
      _testAccount49370Ret = testAccount49370Ret;
    });
  }

  bool _testAccount12586Ret = false;
  Future<void> testAccount12586Async() async {
    bool testAccount12586Ret = await testAccount12586();
    if (!mounted) return;
    setState(() {
      _testAccount12586Ret = testAccount12586Ret;
    });
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

  bool _mainSignPayment0Ret = false;
  Future<void> mainSignPayment0Async() async {
    bool mainSignPayment0Ret = await mainSignPayment0();
    if (!mounted) return;
    setState(() {
      _mainSignPayment0Ret = mainSignPayment0Ret;
    });
  }

  bool _mainSignPayment1Ret = false;
  Future<void> mainSignPayment1Async() async {
    bool mainSignPayment1Ret = await mainSignPayment1();
    if (!mounted) return;
    setState(() {
      _mainSignPayment1Ret = mainSignPayment1Ret;
    });
  }

  bool _mainSignPayment2Ret = false;
  Future<void> mainSignPayment2Async() async {
    bool mainSignPayment2Ret = await mainSignPayment2();
    if (!mounted) return;
    setState(() {
      _mainSignPayment2Ret = mainSignPayment2Ret;
    });
  }

  bool _mainSignPayment3Ret = false;
  Future<void> mainSignPayment3Async() async {
    bool mainSignPayment3Ret = await mainSignPayment3();
    if (!mounted) return;
    setState(() {
      _mainSignPayment3Ret = mainSignPayment3Ret;
    });
  }

  bool _mainSignDelegation0Ret = false;
  Future<void> mainSignDelegation0Async() async {
    bool mainSignDelegation0Ret = await mainSignDelegation0();
    if (!mounted) return;
    setState(() {
      _mainSignDelegation0Ret = mainSignDelegation0Ret;
    });
  }

  bool _mainSignDelegation1Ret = false;
  Future<void> mainSignDelegation1Async() async {
    bool mainSignDelegation1Ret = await mainSignDelegation1();
    if (!mounted) return;
    setState(() {
      _mainSignDelegation1Ret = mainSignDelegation1Ret;
    });
  }

  bool _mainSignDelegation2Ret = false;
  Future<void> mainSignDelegation2Async() async {
    bool mainSignDelegation2Ret = await mainSignDelegation2();
    if (!mounted) return;
    setState(() {
      _mainSignDelegation2Ret = mainSignDelegation2Ret;
    });
  }

  bool _mainSignDelegation3Ret = false;
  Future<void> mainSignDelegation3Async() async {
    bool mainSignDelegation3Ret = await mainSignDelegation3();
    if (!mounted) return;
    setState(() {
      _mainSignDelegation3Ret = mainSignDelegation3Ret;
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
            Text('testAccount0 passed: $_testAccount0Ret'),
            Text('testAccount1 passed: $_testAccount1Ret'),
            Text('testAccount2BE passed: $_testAccount2Ret'),
            Text('testAccount2BE passed: $_testAccount3Ret'),
            Text('testAccount49370BE passed: $_testAccount49370Ret'),
            Text('testAccount12586BE passed: $_testAccount12586Ret'),
            Text('testSignPayment0 passed: $_testSignPayment0Ret'),
            Text('testSignPayment1 passed: $_testSignPayment1Ret'),
            Text('testSignPayment2 passed: $_testSignPayment2Ret'),
            Text('testSignPayment3 passed: $_testSignPayment3Ret'),
            Text('testSignDelegation0 passed: $_testSignDelegation0Ret'),
            Text('testSignDelegation1 passed: $_testSignDelegation1Ret'),
            Text('testSignDelegation2 passed: $_testSignDelegation2Ret'),
            Text('testSignDelegation3 passed: $_testSignDelegation3Ret'),

            Text('mainSignPayment0 passed: $_mainSignPayment0Ret'),
            Text('mainSignPayment1 passed: $_mainSignPayment1Ret'),
            Text('mainSignPayment2 passed: $_mainSignPayment2Ret'),
            Text('mainSignPayment3 passed: $_mainSignPayment3Ret'),
            Text('mainSignDelegation0 passed: $_mainSignDelegation0Ret'),
            Text('mainSignDelegation1 passed: $_mainSignDelegation1Ret'),
            Text('mainSignDelegation2 passed: $_mainSignDelegation2Ret'),
            Text('mainSignDelegation3 passed: $_mainSignDelegation3Ret'),
          ],
        )
      ),
    );
  }
}
