import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/level_model.dart';
import '../../models/lesson_model.dart';
import '../../utils/constants.dart';

class ManageLessons extends StatefulWidget {
  const ManageLessons({super.key});

  @override
  State<ManageLessons> createState() => _ManageLessonsState();
}

class _ManageLessonsState extends State<ManageLessons> {
  final firestore = FirestoreService();
  LevelModel? _selectedLevel;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _youtubeUrlController = TextEditingController();
  final _textContentController = TextEditingController();
  String _lessonType = 'video';
  final _formKey = GlobalKey<FormState>();
  String? _editingLessonId;

  String _extractYoutubeId(String url) {
    if (url.contains('youtu.be/')) {
      return url.split('youtu.be/').last.split('?').first;
    } else if (url.contains('watch?v=')) {
      return url.split('watch?v=').last.split('&').first;
    }
    return url; // assume it's already an ID
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate() || _selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a level and fill all fields')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final lesson = LessonModel(
      id: _editingLessonId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      levelId: _selectedLevel!.id,
      title: _titleController.text,
      description: _descController.text,
      type: _lessonType,
      youtubeId: _lessonType == 'video' ? _extractYoutubeId(_youtubeUrlController.text) : null,
      textContent: _lessonType == 'text' ? _textContentController.text : null,
      order: 0, // order removed
      createdAt: DateTime.now(),
      createdBy: auth.user!.uid,
    );

    await firestore.addLesson(lesson);
    
    _titleController.clear();
    _descController.clear();
    _youtubeUrlController.clear();
    _textContentController.clear();
    setState(() => _editingLessonId = null);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingLessonId != null ? 'Lesson updated' : 'Lesson added successfully')),
      );
    }
  }

  void _editLesson(LessonModel lesson) {
    _titleController.text = lesson.title;
    _descController.text = lesson.description;
    _lessonType = lesson.type;
    if (lesson.type == 'video' && lesson.youtubeId != null) {
      _youtubeUrlController.text = 'https://youtube.com/watch?v=${lesson.youtubeId}';
    }
    if (lesson.type == 'text' && lesson.textContent != null) {
      _textContentController.text = lesson.textContent!;
    }
    setState(() => _editingLessonId = lesson.id);
  }

  void _cancelEdit() {
    _titleController.clear();
    _descController.clear();
    _youtubeUrlController.clear();
    _textContentController.clear();
    setState(() => _editingLessonId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Lessons')),
      body: Column(
        children: [
          // Level Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<List<LevelModel>>(
              stream: firestore.getLevels(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final levels = snapshot.data!;
                if (levels.isEmpty) {
                  return const Card(
                    color: Colors.red,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No levels found. Create a level first.', 
                        style: TextStyle(color: Colors.white)),
                    ),
                  );
                }
                return DropdownButtonFormField<LevelModel>(
                  decoration: const InputDecoration(
                    labelText: 'Select Level',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedLevel,
                  items: levels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level.title),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLevel = value;
                      _cancelEdit();
                    });
                  },
                );
              },
            ),
          ),
          
          // Lessons List
          Expanded(
            child: _selectedLevel == null
                ? const Center(child: Text('Select a level to view lessons'))
                : Column(
                    children: [
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Lessons in ${_selectedLevel!.title}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<List<LessonModel>>(
                          stream: firestore.getLessons(_selectedLevel!.id),
                          builder: (context, lessonSnapshot) {
                            if (lessonSnapshot.hasError) {
                              return Center(child: Text('Error: ${lessonSnapshot.error}'));
                            }
                            if (!lessonSnapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final lessons = lessonSnapshot.data!;
                            if (lessons.isEmpty) {
                              return const Center(child: Text('No lessons yet. Add one below.'));
                            }
                            return ListView.builder(
                              itemCount: lessons.length,
                              itemBuilder: (context, index) {
                                final lesson = lessons[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text('${index + 1}'),
                                    ),
                                    title: Text(lesson.title),
                                    subtitle: Text(lesson.type),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.orange),
                                          onPressed: () => _editLesson(lesson),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () async {
                                            await firestore.deleteLesson(lesson.id);
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Lesson deleted')),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      bottomSheet: _selectedLevel == null
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.card,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_editingLessonId != null ? 'Edit Lesson' : 'Add New Lesson', 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Lesson Title'),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(height: 8),
                      const Text('Lesson Type', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'video', label: Text('Video')),
                          ButtonSegment(value: 'text', label: Text('Text')),
                          ButtonSegment(value: 'document', label: Text('Document')),
                        ],
                        selected: {_lessonType},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            _lessonType = selection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      if (_lessonType == 'video')
                        TextFormField(
                          controller: _youtubeUrlController,
                          decoration: const InputDecoration(
                            labelText: 'YouTube URL',
                            hintText: 'https://youtube.com/watch?v=...',
                          ),
                        ),
                      if (_lessonType == 'text')
                        TextFormField(
                          controller: _textContentController,
                          decoration: const InputDecoration(labelText: 'Text Content'),
                          maxLines: 3,
                        ),
                      if (_lessonType == 'document')
                        const Card(
                          color: Colors.grey,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('PDF upload coming soon'),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveLesson,
                              child: Text(_editingLessonId != null ? 'Update Lesson' : 'Add Lesson'),
                            ),
                          ),
                          if (_editingLessonId != null)
                            const SizedBox(width: 12),
                          if (_editingLessonId != null)
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
            ),
    );
  }
}