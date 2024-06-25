import 'dart:convert';

import 'package:crypto/crypto.dart';

class DigestBuilder {
  static String generateSha256Digest(Object body) {
    final bytes = utf8.encode(body.toString());
    final digest = sha256.convert(bytes);
    return 'SHA-256=${base64.encode(digest.bytes)}';
  }
}
