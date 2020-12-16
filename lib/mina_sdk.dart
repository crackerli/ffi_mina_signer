import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'constant.dart';
import 'mina_signer_native.dart';

class MinaSDK {

  // Copy byte array to native heap
  static Pointer<Uint8> _copyBytesToPointer(Uint8List srcBytes) {
    if(null == srcBytes || 0 == srcBytes.lengthInBytes) {
      return null;
    }

    final len = srcBytes.lengthInBytes;
    final buffer = allocate<Uint8>(count: len);
    for(int i = 0; i < len; i++) {
      buffer[i] = srcBytes[i];
    }

    return buffer;
  }

  // Generate private key with C code.
  static Uint8List genPrivateKey() {
    // Native buffer to store the generated private key
    final nativePrivateKeyBuffer = allocate<Uint8>(count: KEY_BUFFER_SIZE);
    nativeGenPrivateKey(nativePrivateKeyBuffer);

    // Copy the native allocated buffer to Dart heap
    Uint8List dartPrivateKeyBuffer = Uint8List.fromList(nativePrivateKeyBuffer.asTypedList(KEY_BUFFER_SIZE));

    free(nativePrivateKeyBuffer);
    return dartPrivateKeyBuffer;
  }

  // Generate public key with C code.
  static Uint8List getPublicKey(Uint8List privateKey) {
    // Copy the private key data to native heap
    final nativePrivateKeyBuffer = _copyBytesToPointer(privateKey);

    // Native buffer to store the generated public key
    final nativePublicKeyBuffer = allocate<Uint8>(count: KEY_BUFFER_SIZE);

    nativeGenPublicKey(nativePrivateKeyBuffer, nativePublicKeyBuffer);

    // Copy the native allocated buffer to Dart heap
    Uint8List dartPublicKeyBuffer = Uint8List.fromList(nativePublicKeyBuffer.asTypedList(KEY_BUFFER_SIZE));
    free(nativePrivateKeyBuffer);
    free(nativePublicKeyBuffer);
    return dartPublicKeyBuffer;
  }

  static signPayment(

    ) {

  }

  static signDelegation() {

  }

  // Sign message with given private key
  static Uint8List signMessage(Uint8List message, Uint8List privateKey) {
    final nativeMessageBuffer = _copyBytesToPointer(message);
    final nativePrivateKeyBuffer = _copyBytesToPointer(privateKey);
    final nativeSignatureBuffer = allocate<Uint8>(count: KEY_BUFFER_SIZE * 2);

    nativeSignMessage(nativeMessageBuffer, message.lengthInBytes, nativePrivateKeyBuffer, nativeSignatureBuffer);

    // Copy the native allocated buffer to Dart heap
    Uint8List dartSignatureBuffer = Uint8List.fromList(nativeSignatureBuffer.asTypedList(KEY_BUFFER_SIZE * 2));

    free(nativeSignatureBuffer);
    free(nativePrivateKeyBuffer);
    free(nativeMessageBuffer);
    return dartSignatureBuffer;
  }

  static bool verifyMessage() {
    return false;
  }
}
