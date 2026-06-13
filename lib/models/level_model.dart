class LevelModel {
  final String id;
  final String title;
  final String description;
  final int order;
  final DateTime createdAt;
  final String createdBy;
  final String? thumbnailUrl;

  LevelModel({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.createdAt,
    required this.createdBy,
    this.thumbnailUrl,
  });

  factory LevelModel.fromFirestore(Map<String, dynamic> data, String id) {
    return LevelModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as dynamic).toDate(),
      createdBy: data['createdBy'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'order': order,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}