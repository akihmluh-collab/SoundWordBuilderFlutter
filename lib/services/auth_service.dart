import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register new user
  Future<UserModel?> register(String email, String password, String name, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          role: role,
          createdAt: DateTime.now(),
          isActive: true,
        );
        
        await _firestore.collection('users').doc(user.uid).set(newUser.toFirestore());
        return newUser;
      }
    } catch (e) {
      print('Registration error: $e');
    }
    return null;
  }

  // Login user
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return await getUserProfile(result.user!.uid);
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data() as Map<String, dynamic>, uid);
      }
    } catch (e) {
      print('Get user profile error: $e');
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Check subscription expiry
  bool isSubscriptionValid(UserModel user) {
    if (user.role == 'teacher') return true;
    if (user.subscriptionExpiry == null) return false;
    return user.subscriptionExpiry!.isAfter(DateTime.now());
  }

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}