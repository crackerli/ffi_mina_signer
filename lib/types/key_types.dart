import 'dart:typed_data';

class CompressedPublicKey {
  Uint8List x; // 32 bytes list, little endian
  Uint8List isOdd; // 1 byte list

  CompressedPublicKey(Uint8List xCoordinate, Uint8List parity) {
    x = Uint8List.fromList(xCoordinate);
    isOdd = Uint8List.fromList(parity);
  }
}

class PublicKey {
  Uint8List x; // 32 bytes list, little endian
  Uint8List y; // 32 bytes list, little endian

  PublicKey(Uint8List xCoordinate, Uint8List yCoordinate) {
    x = Uint8List.fromList(xCoordinate);
    y = Uint8List.fromList(yCoordinate);
  }

  Uint8List get isOdd {
    var tmp = Uint8List(1);
    tmp[0] = 0;
    return tmp;
  }
}

class Signature {
  final String rx;
  final String s;

  Signature(this.rx, this.s);
}

class Transaction {
  Uint8List sk;
  String memo;
  String feePayerAddress;
  String senderAddress;
  String receiverAddress;
  BigInt fee;
  BigInt feeToken;
  int nonce;
  int validUntil;
  BigInt tokenId;
  BigInt amount;
  int txType;
  int tokenLocked;

  Transaction(this.sk, this.memo, this.feePayerAddress, this.senderAddress, this.receiverAddress, this.fee, this.feeToken,
      this.nonce, this.validUntil, this.tokenId, this.amount, this.txType, this.tokenLocked);
}