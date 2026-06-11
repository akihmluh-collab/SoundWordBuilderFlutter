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
  final firestore = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  String? _editingLevelId;

  Future<void> _saveLevel() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    if (_editingLevelId != null) {
      // Update existing level
      final level = LevelModel(
        id: _editingLevelId!,
        title: _titleController.text,
        description: _descController.text,
        order: 0, // order removed
        createdAt: DateTime.now(),
        createdBy: auth.user!.uid,
      );
      await firestore.addLevel(level); // Firestore will overwrite by id
      setState(() => _editingLevelId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Level updated successfully')),
      );
    } else {
      // Add new level
      final level = LevelModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descController.text,
        order: 0, // order removed
        createdAt: DateTime.now(),
        createdBy: auth.user!.uid,
      );
      await firestore.addLevel(level);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Level added successfully')),
      );
    }
    
    _titleController.clear();
    _descController.clear();
  }

  void _editLevel(LevelModel level) {
    _titleController.text = level.title;
    _descController.text = level.description;
    setState(() => _editingLevelId = level.id);
  }

  void _cancelEdit() {
    _titleController.clear();
    _descController.clear();
    setState(() => _editingLevelId = null);
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveLevel,
                          child: Text(_editingLevelId != null ? 'Update Level' : 'Add Level'),
                        ),
                      ),
                      if (_editingLevelId != null)
                        const SizedBox(width: 12),
                      if (_editingLevelId != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _cancelEdit,
                            child: const Text('Cancel'),
                          ),
                        ),
                    ],
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
                      subtitle: Text(level.description.isNotEmpty ? level.description : 'No description'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _editLevel(level),
                          ),
                          IconButton(
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
                        ],
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