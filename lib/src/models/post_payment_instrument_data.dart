enum PaymentInstrumentState {
  active,
  inactive,
}

class PostPaymentInstrumentData {
  final String id;
  final PaymentInstrumentState state;

  PostPaymentInstrumentData({
    required this.id,
    required this.state,
  });

  factory PostPaymentInstrumentData.fromJson(Map<String, dynamic> json) {
    return PostPaymentInstrumentData(
      id: json['id'],
      state: json['state'] == 'ACTIVE'
          ? PaymentInstrumentState.active
          : PaymentInstrumentState.inactive,
    );
  }
}
