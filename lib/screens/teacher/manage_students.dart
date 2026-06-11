import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';

class ManageStudents extends StatelessWidget {
  const ManageStudents({super.key});

  Future<void> _revokeAccess(BuildContext context, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Access'),
        content: const Text('Are you sure you want to revoke this student\'s subscription access?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Revoke', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'subscriptionExpiry': null,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access revoked')),
        );
      }
    }
  }

  Future<void> _deleteStudent(BuildContext context, String userId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete $name? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deleted')),
        );
      }
    }
  }

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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasSubscription)
                        IconButton(
                          icon: const Icon(Icons.block, color: Colors.orange),
                          onPressed: () => _revokeAccess(context, student.uid),
                          tooltip: 'Revoke Access',
                        ),
                      IconButton(
                        icon: const Icon(Icons.add_card, color: Colors.blue),
                        onPressed: () => _extendSubscription(context, firestore, student),
                        tooltip: 'Extend Subscription',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteStudent(context, student.uid, student.name),
                        tooltip: 'Delete Student',
                      ),
                    ],
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