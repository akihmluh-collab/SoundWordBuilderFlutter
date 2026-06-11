import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/level_model.dart';

class ManageLevels extends StatefulWidget {
  const ManageLevels({super.key});

  @override
  State<ManageLevels> createState() => _ManageLevelsState();
}

class _ManageLevelsState extends State<ManageLevels> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _orderController = TextEditingController();
  final firestore = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  Future<void> _addLevel() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final level = LevelModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descController.text,
      order: int.parse(_orderController.text),
      createdAt: DateTime.now(),
      createdBy: auth.user!.uid,
    );

    await firestore.addLevel(level);
    
    _titleController.clear();
    _descController.clear();
    _orderController.clear();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Level added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Levels')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Level Title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _orderController,
                    decoration: const InputDecoration(labelText: 'Order Number'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addLevel,
                    child: const Text('Add Level'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Existing Levels', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<List<LevelModel>>(
              stream: firestore.getLevels(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final levels = snapshot.data!;
                return ListView.builder(
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    return ListTile(
                      title: Text(level.title),
                      subtitle: Text('Order: ${level.order}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await firestore.deleteLevel(level.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Level deleted')),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}