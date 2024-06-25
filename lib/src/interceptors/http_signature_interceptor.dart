import 'dart:io';

import 'package:cybersource_rest_client_dart/src/digest_builder.dart';
import 'package:cybersource_rest_client_dart/src/http_signature.dart';
import 'package:cybersource_rest_client_dart/src/models/client_config.dart';
import 'package:dio/dio.dart';

class CyberSourceHttpSignatureInterceptor extends Interceptor {
  final CyberSourceClientConfig config;
  late final CyberSourceHttpSignature _httpSignature;

  CyberSourceHttpSignatureInterceptor(this.config)
      : _httpSignature = CyberSourceHttpSignature(config);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    await _signRequest(options);
    return super.onRequest(options, handler);
  }

  Future<void> _signRequest(RequestOptions options) async {
    String? digest;

    if (options.data != null) digest = DigestBuilder.generateSha256Digest(options.data);

    final signature = _httpSignature.generateSignature(
      httpMethod: options.method.toLowerCase(),
      resource: options.path,
      digest: digest,
      host: options.baseUrl.replaceAll('https://', ''),
    );

    options.headers.addAll(
      {
        if (digest != null) 'digest': digest,
        'signature': signature,
        'v-c-merchant-id': config.merchantId,
        'date': HttpDate.format(DateTime.now().toUtc()),
      },
    );
  }
}
