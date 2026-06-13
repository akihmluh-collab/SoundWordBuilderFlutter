import 'package:flutter/material.dart';

class ChildSafetyPolicy extends StatelessWidget {
  const ChildSafetyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Child Safety Policy')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last Updated: June 13, 2026', style: TextStyle(fontSize: 12)),
              SizedBox(height: 16),
              Text('Our Commitment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('SoundWordBuilder is committed to providing a safe, educational environment for children.'),
              SizedBox(height: 16),
              Text('Content Standards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• All videos are pre-screened for age-appropriate content\n• No advertising targeted at children\n• No external links without parental gate\n• No chat or messaging features between users'),
              SizedBox(height: 16),
              Text('Parental Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Parents can:\n\n• Monitor learning progress\n• Reset passwords\n• Cancel subscriptions\n• Contact support for any concerns'),
              SizedBox(height: 16),
              Text('Data Collection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('We only collect:\n\n• Name and email (with parental consent)\n• Learning progress data\n• No location tracking\n• No photo or video uploads'),
              SizedBox(height: 16),
              Text('Reporting Concerns', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('If you have safety concerns: support@soundwordbuilder.com'),
            ],
          ),
        ),
      ),
    );
  }
}