import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _phoneController = TextEditingController();
  String _selectedService = 'MTN';
  bool _isProcessing = false;
  
  final String _manualPhone = '677927714';

  Future<void> _sendWhatsApp() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final message = '''
Hello SoundWordBuilder,

I have made payment of 10,000 XAF via MTN MoMo.
Phone number: ${_phoneController.text}

Please find below my details:
1. Registered email: ${auth.user?.email ?? 'N/A'}
2. Payment screenshot attached separately

Kindly activate my subscription.

Thank you.
''';
    
    final url = 'https://wa.me/237${
      _manualPhone.replaceAll(RegExp(r'[^0-9]'), '')
    }?text=${Uri.encodeComponent(message)}';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please install WhatsApp')),
      );
    }
  }

  Future<void> _processPayment() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // TEMPORARY: Manual payment flow
    // This will be replaced with MeSomb integration later
    
    // For now, redirect to WhatsApp
    await _sendWhatsApp();
    
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text('Amount: 10,000 XAF', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 16),
            Card(
              color: Colors.orange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠️ Manual Payment Instructions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Step 1: Pay 10,000 XAF via MTN MoMo',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Send to: $_manualPhone',
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const Text(
                      'Name: VILIEHSE IRINE ANGU',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '⚠️ Confirm the name before sending money!',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Step 2: Click "Confirm Payment via WhatsApp" below',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Step 3: Send your registered email and payment screenshot',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Step 4: Teacher will activate your access within 24 hours',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const Text(
                      '🔜 Automatic payment coming soon.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'MTN', label: Text('MTN Money')),
                ButtonSegment(value: 'ORANGE', label: Text('Orange Money')),
              ],
              selected: {_selectedService},
              onSelectionChanged: (Set<String> selection) {
                setState(() => _selectedService = selection.first);
              },
            ),
            
            const SizedBox(height: 24),
            
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                hintText: '6XXXXXXXX',
              ),
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: 24),
            
            _isProcessing
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Confirm Payment via WhatsApp'),
                  ),
          ],
        ),
      ),
    );
  }
}