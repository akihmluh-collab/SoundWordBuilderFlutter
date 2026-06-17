import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class MeSombPaymentService {
  static const String baseUrl = 'https://mesomb.hachther.com/en/api/v1.1/payment/collect/';
  static const String applicationKey = 'f88b7c9c4cd8efdc5a826b9fc3217d1835e2153c';
  static const String accessKey = '86f6d5dc-de6a-4f45-950d-54f500930a36';
  static const String secretKey = '0c6a6380-bb4e-40ae-8fe4-0ac7e72f9c03';

  String _generateNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  String _generateTimestamp() {
    // Unix timestamp in seconds as string
    return (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000).toString();
  }

  Future<Map<String, dynamic>> collectPayment({
    required int amount,
    required String phoneNumber,
    required String service,
  }) async {
    final uri = Uri.parse(baseUrl);
    const method = 'POST';
    final date = _generateTimestamp();   // Unix timestamp e.g. "1666091223"
    final nonce = _generateNonce();

    final bodyMap = {
      'amount': amount,
      'service': service,
      'payer': phoneNumber.trim(),
      'nonce': nonce,
      'country': 'CM',
      'currency': 'XAF',
    };
    // Compact JSON — no extra spaces
    final body = jsonEncode(bodyMap);

    // STEP 1: Build Canonical Request
    // HashedPayload = hex(SHA1(body))
    final hashedPayload = sha1.convert(utf8.encode(body)).toString();

    // Canonical headers — use x-mesomb-date and x-mesomb-nonce (NOT x-mes-date)
    final canonicalHeaders =
        'host:mesomb.hachther.com\n'
        'x-mesomb-date:$date\n'
        'x-mesomb-nonce:$nonce\n';

    final signedHeaders = 'host;x-mesomb-date;x-mesomb-nonce';

    final canonicalRequest = [
      method,
      '/en/api/v1.1/payment/collect/',
      '',            // query string (empty)
      canonicalHeaders,
      signedHeaders,
      hashedPayload,
    ].join('\n');

    // STEP 2: Build String to Sign
    // "HMAC-SHA1\n" + timestamp + "\n" + scope + "\n" + Hex(SHA1(canonicalRequest))
    final scope = '$date/mesomb_request';
    final hashedCanonical = sha1.convert(utf8.encode(canonicalRequest)).toString();

    final stringToSign = [
      'HMAC-SHA1',
      date,
      scope,
      hashedCanonical,
    ].join('\n');

    // STEP 3: Compute HMAC-SHA1 signature
    final signingKey = utf8.encode(secretKey);
    final hmacSha1 = Hmac(sha1, signingKey);
    final signatureBytes = hmacSha1.convert(utf8.encode(stringToSign));
    final signatureHex = signatureBytes.toString(); // hex string

    // STEP 4: Build Authorization header
    final authorization =
        'HMAC-SHA1 AccessKey=$accessKey, '
        'Date=$date, '
        'Nonce=$nonce, '
        'SignedHeaders=$signedHeaders, '
        'Signature=$signatureHex';

    final headers = {
      'Content-Type': 'application/json',
      'X-MeSomb-Application': applicationKey,
      'X-MeSomb-Date': date,
      'X-MeSomb-Nonce': nonce,
      'Authorization': authorization,
    };

    try {
      final response = await http.post(uri, headers: headers, body: body);
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'status': data['status'],
          'transactionId': data['pk'],
          'message': data['message'] ?? 'Payment successful',
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('Payment error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}