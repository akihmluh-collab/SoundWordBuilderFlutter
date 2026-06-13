class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? phone;
  final String role;
  final DateTime createdAt;
  final DateTime? subscriptionExpiry;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    required this.createdAt,
    this.subscriptionExpiry,
    required this.isActive,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'],
      role: data['role'] ?? 'student',
      createdAt: (data['createdAt'] as dynamic).toDate(),
      subscriptionExpiry: data['subscriptionExpiry'] != null 
          ? (data['subscriptionExpiry'] as dynamic).toDate() 
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'createdAt': createdAt,
      'subscriptionExpiry': subscriptionExpiry,
      'isActive': isActive,
    };
  }
}