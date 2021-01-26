# ffi_mina_signer

A Flutter Plugin To Operate Key Pairs Of Mina Protocol, With C Code Support.
This Plugin support BIP32, BIP39, BIP44, all mina accounts will derive from m/44'/12586'/account'/0'/0'

## How to use
1. public APIs are described in mina_signer_sdk.dart
2. Data switch between Dart and C heap should follow below conventions: 

   a) Common memory data use Uint8List in Dart, and mapping to uint8_t* in C 
   
   b) String passing should be utf8 encoded, and add ending 0 for C string usage. 
   
   c) Uint64 stored as BigInt in dart vm, and if you want to pass BigInt to C layer, please convert BigInt to bytes array with little endian. 
   

## Core curve C code path:
ios/Classes/mina_native_signer

## Extra porting C code:
porting.c; porting.h

## Test Cases listed in ffi_mina_signer/example/lib/test/tests.dart

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

