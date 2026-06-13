import 'package:flutter/material.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last Updated: June 13, 2026', style: TextStyle(fontSize: 12)),
              SizedBox(height: 16),
              Text('Acceptance of Terms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('By using SoundWordBuilder, you agree to these Terms of Service.'),
              SizedBox(height: 16),
              Text('Subscription', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Monthly subscription: 10,000 XAF\n• Payment is processed via MTN or Orange Money\n• Subscriptions auto-renew monthly unless cancelled\n• Refunds are not provided for partial months'),
              SizedBox(height: 16),
              Text('User Conduct', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('You agree to use the app for educational purposes only and not to share your account with others.'),
              SizedBox(height: 16),
              Text('Content Ownership', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('All educational content is owned by SoundWordBuilder. You may not redistribute or copy content without permission.'),
              SizedBox(height: 16),
              Text('Termination', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('We may terminate your access for violation of these terms or non-payment.'),
              SizedBox(height: 16),
              Text('Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('For questions: support@soundwordbuilder.com'),
            ],
          ),
        ),
      ),
    );
  }
}