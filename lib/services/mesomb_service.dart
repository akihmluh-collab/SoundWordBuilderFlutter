import 'dart:convert';
import 'package:http/http.dart' as http;

class MeSombService {
  static const String baseUrl = 'https://mesomb.hachther.com/api/v1.1/payments/online/';
  
  static const String applicationKey = 'f88b7c9c4cd8efdc5a826b9fc3217d1835e2153c';
  static const String accessKey = '86f6d5dc-de6a-4f45-950d-54f500930a36';
  static const String secretKey = '0c6a6380-bb4e-40ae-8fe4-0ac7e72f9c03';

  Future<Map<String, dynamic>> initiatePayment({
    required double amount,
    required String phoneNumber,
    required String provider,
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrl$provider/');
    
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    
    final headers = {
      'Content-Type': 'application/json',
      'x-mesomb-application': applicationKey,
      'x-mesomb-access': accessKey,
      'x-mesomb-secret': secretKey,
      'x-mesomb-date': timestamp,
    };
    
    final body = jsonEncode({
      'amount': amount,
      'payer': phoneNumber,
      'fees': false,
      'currency': 'XAF',
      'service': provider,
      'location': 'CM',
    });
    
    try {
      final response = await http.post(url, headers: headers, body: body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error', 
          'message': 'HTTP ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}