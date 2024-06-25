// cybersource_rest_client_test.dart
import 'package:cybersource_rest_client_dart/cybersource_rest_client_dart.dart';
import 'package:cybersource_rest_client_dart/src/dio_client.dart';
import 'package:cybersource_rest_client_dart/src/exceptions/payment_instrument_exception.dart';
import 'package:cybersource_rest_client_dart/src/models/client_config.dart';
import 'package:cybersource_rest_client_dart/src/models/post_payment_instrument_request.dart';
import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'faker_utils.dart';

class MockDioClient extends Mock implements DioClient {}

class FakePostPaymentInstrumentBody extends Fake implements PostPaymentInstrumentBody {
  @override
  Map<String, dynamic> toJson() => {};
}

void main() {
  final faker = Faker();

  group('CyberSourceRestClient', () {
    late CyberSourceClientConfig config;
    late DioClient mockDioClient;
    late CybersourceRestClient client;

    setUp(() {
      config = CyberSourceClientConfig(
        merchantId: faker.lorem.word().toLowerCase(),
        keyId: faker.guid.guid(),
        sharedSecretKey: faker.randomGenerator.cybersourceSharedSecretKey(),
      );
      mockDioClient = MockDioClient();
      client = CybersourceRestClient(
        config,
        dioClient: mockDioClient,
      );
    });

    tearDown(() {
      reset(mockDioClient);
    });

    test(
      'Should call post with correct body',
      () async {
        final postPaymentInstrumentBody = PostPaymentInstrumentBody(
          cardNumber: '4111111111111111',
          expirationYear: faker.randomGenerator.integer(2030, min: DateTime.now().year).toString(),
          expirationMonth: faker.randomGenerator.integer(12, min: 1).toString().padLeft(2, '0'),
          holderName: 'John Doe Tester',
        );

        when(() => mockDioClient.post('/tms/v1/paymentinstruments', body: any(named: 'body')))
            .thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 201,
            data: {
              'id': faker.guid.guid(),
              'state': 'ACTIVE',
            },
          ),
        );

        await client.createPaymentInstrument(postPaymentInstrumentBody);

        final bodyParams = verify(
          () => mockDioClient.post(any(), body: captureAny(named: 'body')),
        ).captured.single as Map<String, dynamic>;

        expect(bodyParams['billTo'], isNotNull);
        expect(bodyParams['billTo']['firstName'], 'John');
        expect(bodyParams['billTo']['lastName'], 'Doe Tester');
        expect(bodyParams['card'], isNotNull);
        expect(bodyParams['instrumentIdentifier'], isNotNull);
        expect(bodyParams, postPaymentInstrumentBody.toJson());
      },
    );

    test('Should return id for successful payment instrument creation', () async {
      final paymentInstrumentId = faker.guid.guid();

      when(() => mockDioClient.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 201,
          data: {
            'id': paymentInstrumentId,
            'state': 'ACTIVE',
          },
        ),
      );

      var result = await client.createPaymentInstrument(FakePostPaymentInstrumentBody());

      expect(result, paymentInstrumentId);
    });

    test('Should throw exception for inactive payment instrument', () async {
      when(() => mockDioClient.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 201,
          data: {
            'id': faker.guid.guid(),
            'state': 'INACTIVE',
          },
        ),
      );

      expect(
        () async => await client.createPaymentInstrument(FakePostPaymentInstrumentBody()),
        throwsA(isA<InactivePaymentInstrumentException>()),
      );
    });

    test('Should throw exception for unsuccessful payment instrument creation', () async {
      final errorMessage = faker.lorem.sentence();

      when(() => mockDioClient.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 410,
          data: errorMessage,
        ),
      );

      expect(
        () async => await client.createPaymentInstrument(FakePostPaymentInstrumentBody()),
        throwsA(predicate((e) => e is PaymentInstrumentException && e.message == errorMessage)),
      );
    });

    test('should throw exception for invalid PostPaymentInstrumentBody card number', () async {
      when(() => mockDioClient.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 201,
          data: {
            'id': faker.guid.guid(),
            'state': 'ACTIVE',
          },
        ),
      );

      expect(
        () async => await client.createPaymentInstrument(
          PostPaymentInstrumentBody(
            cardNumber: '123443212344321',
            expirationMonth: '12',
            expirationYear: '2031',
          ),
        ),
        throwsA(isA<InvalidCardNumberException>()),
      );
    });

    test('should throw exception for invalid PostPaymentInstrumentBody expiration month', () async {
      when(() => mockDioClient.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 201,
          data: {
            'id': faker.guid.guid(),
            'state': 'ACTIVE',
          },
        ),
      );

      expect(
        () async => await client.createPaymentInstrument(
          PostPaymentInstrumentBody(
            cardNumber: '4111111111111111',
            expirationMonth: faker.randomGenerator.integer(99, min: 13).toString().padLeft(2, '0'),
            expirationYear: '2031',
          ),
        ),
        throwsA(isA<InvalidCardExpirationException>()),
      );
    });
  });
}
