import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _getUserData(result.user!.uid);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user!.updateDisplayName(name);

      // Create user document
      UserModel userModel = UserModel(
        userId: result.user!.uid,
        name: name,
        email: email,
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(userModel.toMap());

      return userModel;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  Future<UserModel?> _getUserData(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    return await _getUserData(userId);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}


