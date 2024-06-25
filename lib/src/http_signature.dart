import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cybersource_rest_client_dart/src/models/client_config.dart';

const String algorithm = 'HmacSHA256';

class CyberSourceHttpSignature {
  CyberSourceHttpSignature(this.config);

  final CyberSourceClientConfig config;

  String generateSignature({
    required String host,
    required String httpMethod,
    required String resource,
    String? digest,
  }) {
    try {
      final params = [
        'host: $host\n',
        'request-target: $httpMethod $resource\n',
        if (digest != null) 'digest: $digest\n',
        'v-c-merchant-id: ${config.merchantId}',
      ].join();

      final paramsSignature = _getSignatureFromParams(params);
      final headers = [
        'host',
        'request-target',
        if (digest != null) 'digest',
        'v-c-merchant-id',
      ].join(' ');

      return [
        'keyid="${config.keyId}"',
        'algorithm="$algorithm"',
        'headers="$headers"',
        'signature="$paramsSignature"'
      ].join(', ');
    } catch (e) {
      throw Exception('Error generating signature: $e');
    }
  }

  String _getSignatureFromParams(String params) {
    var decodedSharedSecretKey = base64.decode(config.sharedSecretKey);
    var hmacSha256 = Hmac(sha256, decodedSharedSecretKey);
    var paramsDigest = hmacSha256.convert(utf8.encode(params));

    return base64.encode(paramsDigest.bytes);
  }
}
