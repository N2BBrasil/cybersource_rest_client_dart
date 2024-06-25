import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:cybersource_rest_client_dart/src/card_utils.dart';
import 'package:cybersource_rest_client_dart/src/exceptions/payment_instrument_exception.dart';

class PostPaymentInstrumentBody {
  final String _cardNumber;
  final String expirationMonth;
  final String expirationYear;
  final String? holderName;

  PostPaymentInstrumentBody({
    required String cardNumber,
    required this.expirationMonth,
    required this.expirationYear,
    this.holderName,
  }) : _cardNumber = cardNumber.replaceAll(RegExp(r'\D'), '') {
    if (!RegExp(r'^\d{2}$').hasMatch(expirationMonth) ||
        int.parse(expirationMonth) <= 0 ||
        int.parse(expirationMonth) > 12) {
      throw InvalidCardExpirationException(
        'expirationMonth must be a two digit number between 1 and 12',
      );
    }

    if (!RegExp(r'^\d{4}$').hasMatch(expirationYear) || int.parse(expirationYear) <= 0) {
      throw InvalidCardExpirationException(
        'expirationYear must be a four digit number greater than 0',
      );
    }

    if (!CardUtils.validateCardNumber(cardNumber)) {
      throw InvalidCardNumberException();
    }
  }

  String get cardType {
    final detectedTypes = detectCCType(_cardNumber);
    return detectedTypes.first.type.replaceAll('_', '  ');
  }

  Map<String, dynamic> toJson() {
    return {
      "card": {
        'expirationMonth': expirationMonth,
        'expirationYear': expirationYear,
        'type': cardType,
      },
      "instrumentIdentifier": {
        "card": {
          "number": _cardNumber,
        }
      },
      if (holderName != null) ...{
        "billTo": () {
          final splitName = holderName!.split(' ');

          return {
            "firstName": splitName.first,
            "lastName": splitName.length >= 3 ? splitName.sublist(1).join(' ') : splitName.last,
          };
        }.call(),
      }
    };
  }
}
