import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggerInterceptor extends Interceptor {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0, printEmojis: false));

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d(
      'Request `${options.method} ${options.path}`\n'
      'Headers: ${_prettyPrintJson(options.headers)}\n'
      '${_prettyPrintJson(options.data)}',
      time: DateTime.now(),
    );

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i(
      'Response ${response.statusCode} ${response.statusMessage}\n'
      '${_prettyPrintJson(response.data)}',
    );

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      'Response ERROR ${err.response?.statusCode} ${err.response?.statusMessage}\n'
      '${_prettyPrintJson(err.response?.data)}',
      error: err.error,
    );

    super.onError(err, handler);
  }

  String _prettyPrintJson(dynamic data) {
    if (data is Map || data is List) return const JsonEncoder.withIndent('  ').convert(data);
    return data.toString();
  }
}
