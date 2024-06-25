library cybersource_rest_client_dart;

import 'package:cybersource_rest_client_dart/src/dio_client.dart';
import 'package:cybersource_rest_client_dart/src/exceptions/payment_instrument_exception.dart';
import 'package:cybersource_rest_client_dart/src/models/client_config.dart';
import 'package:cybersource_rest_client_dart/src/models/post_payment_instrument_data.dart';
import 'package:cybersource_rest_client_dart/src/models/post_payment_instrument_request.dart';
import 'package:flutter/material.dart';

export 'src/models/client_config.dart';
export 'src/models/post_payment_instrument_request.dart';

class CybersourceRestClient {
  CybersourceRestClient(
    this.config, {
    bool debug = false,
    @visibleForTesting DioClient? dioClient,
  }) : _dioClient = dioClient ?? DioClient(config, debug: debug);

  final DioClient _dioClient;
  final CyberSourceClientConfig config;

  Future<String> createPaymentInstrument(PostPaymentInstrumentBody body) async {
    final response = await _dioClient.post('/tms/v1/paymentinstruments', body: body.toJson());

    if (response.statusCode == 201) {
      final data = PostPaymentInstrumentData.fromJson(response.data);

      if (data.state == PaymentInstrumentState.active) return data.id;

      throw InactivePaymentInstrumentException('Payment instrument is inactive');
    }

    throw PaymentInstrumentException(response.data.toString());
  }
}
