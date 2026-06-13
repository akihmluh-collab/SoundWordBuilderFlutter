import 'package:flutter/material.dart';

class RefundPolicy extends StatelessWidget {
  const RefundPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refund Policy')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last Updated: June 13, 2026', style: TextStyle(fontSize: 12)),
              SizedBox(height: 16),
              Text('Refund Policy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('At SoundWordBuilder, we strive to provide quality educational content. However, due to the digital nature of our service, we have a limited refund policy.'),
              SizedBox(height: 16),
              Text('Eligibility for Refunds', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Refunds may be issued within 7 days of purchase if:\n\n• Technical issues prevent access to content\n• Duplicate payment was processed\n• You were charged after cancellation\n\nRefunds are NOT provided for:\n\n• Change of mind\n• Partial usage of subscription period\n• Failure to use the service'),
              SizedBox(height: 16),
              Text('How to Request a Refund', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Contact support@soundwordbuilder.com with your payment reference and reason for refund.'),
              SizedBox(height: 16),
              Text('Processing Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Approved refunds will be processed within 5-10 business days.'),
            ],
          ),
        ),
      ),
    );
  }
}