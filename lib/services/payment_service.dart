import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  // Mesombé API - replace with actual credentials
  static const String apiKey = 'YOUR_MESOMBE_API_KEY';
  static const String apiSecret = 'YOUR_MESOMBE_SECRET';
  static const String baseUrl = 'https://sandbox.mesombé.com/v1/online/payments';

  Future<bool> processPayment({
    required double amount,
    required String phoneNumber,
    required String provider, // 'mtn' or 'orange'
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$provider/'),
        headers: {
          'Content-Type': 'application/json',
          'X-Mesombe-Key': apiKey,
          'X-Mesombe-Secret': apiSecret,
        },
        body: jsonEncode({
          'amount': amount,
          'payer': phoneNumber,
          'fee': 0,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['status'] == 'SUCCESS';
      }
      return false;
    } catch (e) {
      print('Payment error: $e');
      return false;
    }
  }
}