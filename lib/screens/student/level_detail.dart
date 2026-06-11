import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/level_model.dart';
import '../../models/lesson_model.dart';
import '../../utils/constants.dart';
import 'lesson_viewer.dart';

class LevelDetail extends StatelessWidget {
  final LevelModel level;
  const LevelDetail({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final hasSubscription = Provider.of<AuthProvider>(context).hasActiveSubscription;

    return Scaffold(
      appBar: AppBar(title: Text(level.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (level.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(level.description, style: const TextStyle(fontSize: 14)),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StreamBuilder<List<LessonModel>>(
              stream: firestore.getLessons(level.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final lessons = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${lessons.length} Lessons', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...lessons.asMap().entries.map((entry) {
                      final index = entry.key;
                      final lesson = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text(lesson.title),
                          subtitle: Text(lesson.type),
                          trailing: const Icon(Icons.play_arrow),
                          onTap: hasSubscription
                              ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonViewer(lesson: lesson)))
                              : null,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}