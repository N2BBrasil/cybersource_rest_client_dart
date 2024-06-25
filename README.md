# CyberSource REST Client for Dart

This is a Dart package for interacting with the CyberSource REST API. It provides a convenient way to generate HTTP signatures for secure communication with the CyberSource API.

## Features

- Communicate with the CyberSource REST API using Dart
- Generate HTTP signatures for secure communication with the CyberSource API

## Getting Started

To use this package, add `cybersource_rest_client_dart` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  cybersource_rest_client_dart: ^0.0.1
```

## Usage
Here's a simple example of using this package to create a payment instrument:
```dart

CybersourceRestClient cybersourceRestClient = CybersourceRestClient(
  CyberSourceClientConfig(
    merchantId: "your_merchant_id",
    keyId: "your_key_id",
    sharedSecretKey: "your_shared_secret_key",
  ),
  debug: true,
);

final paymentInstrumentId = cybersourceRestClient.createPaymentInstrument(
    PostPaymentInstrumentBody(
      cardNumber: "4111111111111111",
      expirationMonth: "12",
      expirationYear: "2031",
    )
);
```

## Testing
This package includes unit tests. To run the tests, use the dart test command in your terminal. 

## Contributing
Contributions are welcome! Please read our contributing guidelines to get started.