import 'dart:convert';

import 'package:cybersource_rest_client_dart/src/interceptors/http_signature_interceptor.dart';
import 'package:cybersource_rest_client_dart/src/interceptors/logger_interceptor.dart';
import 'package:cybersource_rest_client_dart/src/models/client_config.dart';
import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient(
    CyberSourceClientConfig config, {
    bool debug = false,
  }) : _dio = Dio(BaseOptions(baseUrl: config.uri.toString())) {
    addInterceptor(CyberSourceHttpSignatureInterceptor(config));
    if (debug) addInterceptor(LoggerInterceptor());
  }

  void addInterceptor(Interceptor interceptor) => _dio.interceptors.add(interceptor);

  Future<Response> post(String path, {Object? body}) async {
    final data = _parseToBodyText(body);

    final response = await _dio.post(
      path,
      data: data,
    );

    return response;
  }

  String? _parseToBodyText(Object? data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map<String, dynamic>) return jsonEncode(data);
    if (data is List) return jsonEncode(data);
    throw ArgumentError('Invalid data type');
  }
}
