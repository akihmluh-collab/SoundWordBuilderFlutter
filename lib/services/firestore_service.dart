import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/level_model.dart';
import '../models/lesson_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Levels
  Stream<List<LevelModel>> getLevels() {
    return _firestore
        .collection('levels')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LevelModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> addLevel(LevelModel level) async {
    await _firestore.collection('levels').doc(level.id).set(level.toFirestore());
  }

  Future<void> deleteLevel(String levelId) async {
    await _firestore.collection('levels').doc(levelId).delete();
  }

  // Lessons
  Stream<List<LessonModel>> getLessons(String levelId) {
    return _firestore
        .collection('lessons')
        .where('levelId', isEqualTo: levelId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LessonModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> addLesson(LessonModel lesson) async {
    await _firestore.collection('lessons').doc(lesson.id).set(lesson.toFirestore());
  }

  Future<void> deleteLesson(String lessonId) async {
    await _firestore.collection('lessons').doc(lessonId).delete();
  }

  // Students
  Stream<List<UserModel>> getStudents() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateSubscription(String userId, DateTime expiry) async {
    await _firestore.collection('users').doc(userId).update({
      'subscriptionExpiry': expiry,
    });
  }
}
