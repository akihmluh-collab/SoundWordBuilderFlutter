class LessonModel {
  final String id;
  final String levelId;
  final String title;
  final String description;
  final String type; // 'video', 'document', 'text'
  final String? youtubeId;
  final String? documentUrl;
  final String? textContent;
  final int order;
  final DateTime createdAt;
  final String createdBy;
  final String? duration;

  LessonModel({
    required this.id,
    required this.levelId,
    required this.title,
    required this.description,
    required this.type,
    this.youtubeId,
    this.documentUrl,
    this.textContent,
    required this.order,
    required this.createdAt,
    required this.createdBy,
    this.duration,
  });

  factory LessonModel.fromFirestore(Map<String, dynamic> data, String id) {
    return LessonModel(
      id: id,
      levelId: data['levelId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'text',
      youtubeId: data['youtubeId'],
      documentUrl: data['documentUrl'],
      textContent: data['textContent'],
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as dynamic).toDate(),
      createdBy: data['createdBy'] ?? '',
      duration: data['duration'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'levelId': levelId,
      'title': title,
      'description': description,
      'type': type,
      'youtubeId': youtubeId,
      'documentUrl': documentUrl,
      'textContent': textContent,
      'order': order,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'duration': duration,
    };
  }
}