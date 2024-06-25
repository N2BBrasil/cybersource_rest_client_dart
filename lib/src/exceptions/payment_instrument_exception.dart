class PaymentInstrumentException implements Exception {
  final String? message;

  PaymentInstrumentException([this.message]);

  @override
  String toString() => 'PaymentInstrumentException:${message ?? ''}';
}

class InactivePaymentInstrumentException extends PaymentInstrumentException {
  InactivePaymentInstrumentException([super.message]);
}

class InvalidCardExpirationException extends PaymentInstrumentException {
  InvalidCardExpirationException([super.message]);
}

class InvalidCardNumberException extends PaymentInstrumentException {
  InvalidCardNumberException([super.message]);
}
