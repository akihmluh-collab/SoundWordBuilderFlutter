import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/mesomb_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _phoneController = TextEditingController();
  String _provider = 'mtn';
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final firestore = FirestoreService();
    final mesomb = MeSombService();

    final result = await mesomb.initiatePayment(
      amount: 10000,
      phoneNumber: _phoneController.text,
      provider: _provider,
      userId: auth.user!.uid,
    );

    if (result['status'] == 'SUCCESS') {
      final expiryDate = DateTime.now().add(const Duration(days: 30));
      await firestore.updateSubscription(auth.user!.uid, expiryDate);
      await auth.refreshUser();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful! Subscription activated for 30 days.')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${result['message'] ?? 'Try again'}')),
        );
      }
    }

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
            const SizedBox(height: 40),
            const Text('Amount: 10,000 XAF', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'mtn', label: Text('MTN Money')),
                ButtonSegment(value: 'orange', label: Text('Orange Money')),
              ],
              selected: {_provider},
              onSelectionChanged: (Set<String> selection) {
                setState(() => _provider = selection.first);
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
            const SizedBox(height: 32),
            _isProcessing
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text('Pay Now'),
                  ),
          ],
        ),
      ),
    );
  }
}