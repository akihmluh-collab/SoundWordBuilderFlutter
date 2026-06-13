import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last Updated: June 13, 2026', style: TextStyle(fontSize: 12)),
              SizedBox(height: 16),
              Text('Information We Collect', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('We collect name, email address, and learning progress data to provide educational services.'),
              SizedBox(height: 16),
              Text('How We Use Your Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• To provide and maintain our educational service\n• To notify you about changes to our service\n• To provide customer support\n• To monitor usage of the app'),
              SizedBox(height: 16),
              Text('Data Security', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('We use Firebase security rules and encryption to protect your data.'),
              SizedBox(height: 16),
              Text('Children\'s Privacy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('This app is designed for children. Parental supervision is recommended. We do not knowingly collect personal information from children under 13 without parental consent.'),
            ],
          ),
        ),
      ),
    );
  }
}