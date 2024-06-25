import 'package:cybersource_rest_client_dart/cybersource_rest_client_dart.dart';

main(List<String> arguments) async {
  CybersourceRestClient cybersourceRestClient = CybersourceRestClient(
    CyberSourceClientConfig(
      merchantId: "",
      keyId: "",
      sharedSecretKey: "",
    ),
    debug: true,
  );

  await cybersourceRestClient.createPaymentInstrument(
    PostPaymentInstrumentBody(
      cardNumber: "4111111111111111",
      expirationMonth: "12",
      expirationYear: "2031",
    ),
  );
}
