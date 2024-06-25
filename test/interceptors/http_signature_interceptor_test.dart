import 'dart:convert';

import 'package:cybersource_rest_client_dart/src/interceptors/http_signature_interceptor.dart';
import 'package:cybersource_rest_client_dart/src/models/client_config.dart';
import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../faker_utils.dart';

void main() {
  final faker = Faker();

  group('CyberSourceHttpSignatureInterceptor Test', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late CyberSourceClientConfig config;
    late String path;

    setUpAll(() {
      config = CyberSourceClientConfig(
        merchantId: faker.lorem.word().toLowerCase(),
        keyId: faker.guid.guid(),
        sharedSecretKey: faker.randomGenerator.cybersourceSharedSecretKey(),
      );
    });

    setUp(() {
      dio = Dio(
        BaseOptions(
          validateStatus: (status) =>
              true, // We need to set this to avoid unnecessary throwing exception when we expect an error status.
        ),
      );
      dioAdapter = DioAdapter(dio: dio);
      path = faker.internet.httpsUrl();
    });

    tearDown(() {
      dio.close();
      dioAdapter.close();
    });

    test('Interceptor adds signature headers to request.', () async {
      dio.httpClientAdapter = dioAdapter;
      final interceptor = CyberSourceHttpSignatureInterceptor(config);
      dio.interceptors.add(interceptor);

      dioAdapter.onPost(
        path,
        (request) => request.reply(200, {'message': 'success'}),
        data: Matchers.any,
      );

      final response = await dio.post(path);

      expect(response.statusCode, 200);
      expect(response.requestOptions.headers.containsKey('signature'), true);
      expect(response.requestOptions.headers.containsKey('date'), true);
      expect(response.requestOptions.headers.containsKey('v-c-merchant-id'), true);
    });

    test('Interceptor adds digest header to request with body.', () async {
      dio.httpClientAdapter = dioAdapter;
      final interceptor = CyberSourceHttpSignatureInterceptor(config);
      dio.interceptors.add(interceptor);

      dioAdapter.onPost(
        path,
        (request) => request.reply(200, {'message': 'success'}),
        data: Matchers.any,
      );

      final response = await dio.post(
        path,
        data: jsonEncode({'data': faker.lorem.sentence()}),
      );

      expect(response.statusCode, 200);
      expect(response.requestOptions.headers.containsKey('digest'), true);
    });

    test('Interceptor does not add digest header to request without body.', () async {
      dio.httpClientAdapter = dioAdapter;
      final interceptor = CyberSourceHttpSignatureInterceptor(config);
      dio.interceptors.add(interceptor);

      dioAdapter.onGet(
        path,
        (request) => request.reply(200, {'message': 'success'}),
      );

      final response = await dio.get(path);

      expect(response.statusCode, 200);
      expect(response.requestOptions.headers.containsKey('digest'), false);
    });
  });
}
