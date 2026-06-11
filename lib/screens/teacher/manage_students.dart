import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';

class ManageStudents extends StatelessWidget {
  const ManageStudents({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Students')),
      body: StreamBuilder<List<UserModel>>(
        stream: firestore.getStudents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final students = snapshot.data!;
          
          if (students.isEmpty) {
            return const Center(child: Text('No students found'));
          }
          
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final hasSubscription = student.subscriptionExpiry != null && 
                  student.subscriptionExpiry!.isAfter(DateTime.now());
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(student.name[0].toUpperCase()),
                  ),
                  title: Text(student.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.email),
                      const SizedBox(height: 4),
                      Text(
                        hasSubscription 
                            ? 'Active until: ${student.subscriptionExpiry!.toLocal().toString().split(' ')[0]}'
                            : 'No active subscription',
                        style: TextStyle(
                          fontSize: 12,
                          color: hasSubscription ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_card, color: Colors.blue),
                    onPressed: () => _extendSubscription(context, firestore, student),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _extendSubscription(BuildContext context, FirestoreService firestore, UserModel student) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      await firestore.updateSubscription(student.uid, date);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription extended until ${date.toLocal().toString().split(' ')[0]}')),
        );
      }
    }
  }
}