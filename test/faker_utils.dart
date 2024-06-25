import 'dart:convert';

import 'package:faker/faker.dart';

extension FakerCybersourceSharedSecretKeyGeneratorExt on RandomGenerator {
  String cybersourceSharedSecretKey() {
    return base64.encode(utf8.encode(faker.guid.guid()));
  }
}
