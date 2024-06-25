enum CybersourceEnvironment {
  sandbox._('apitest.cybersource.com'),
  production._('api.cybersource.com');

  const CybersourceEnvironment._(this.host);

  final String host;
}

class CyberSourceClientConfig {
  CyberSourceClientConfig({
    required this.merchantId,
    required this.keyId,
    required this.sharedSecretKey,
    this.environment = CybersourceEnvironment.sandbox,
    String? host,
  }) : _host = host ?? environment.host;

  final String merchantId;
  final String keyId;
  final String sharedSecretKey;
  final CybersourceEnvironment environment;
  final String _host;

  String get host => _host;

  Uri get uri => Uri.parse('https://$host');
}
