import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:malinaowaterbilling/core/constants/firebase_constants.dart';
import 'package:malinaowaterbilling/features/auth/domain/repository/auth_repo.dart';
import 'package:malinaowaterbilling/features/users/domain/entity/user.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String userTablename = FirebaseConstants.users;

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw Exception('No User Logged in!');

      await firestore.collection(userTablename).doc(user.uid).delete();
      await user.delete();
      await logout();
    } catch (ex) {
      throw Exception('Delete account failed: ${ex.toString()}');
    }
  }

  // In your FirebaseAuthRepo
  @override
  Future<UserModel?> getCurrentAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      final userDoc = await firestore
          .collection(userTablename)
          .doc(user.uid)
          .get();
      if (!userDoc.exists) return null;

      final data = userDoc.data()!;
      return UserModel.fromMap(data);
    } catch (ex) {
      throw Exception('Get current account failed: ${ex.toString()}');
    }
  }

  @override
  Future<UserModel?> loginWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await firestore
          .collection(userTablename)
          .doc(userCredential.user!.uid)
          .get();
      if (!userDoc.exists) {
        throw Exception('User profile not found. Please contact support.');
      }

      final data = userDoc.data()!;
      return UserModel.fromMap(data);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with that email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        case 'invalid-credential':
          message = 'Invalid email or password.';
          break;
        case 'user-disabled':
          message = 'Your account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        default:
          message =
              'Login failed: ${e.message ?? "Please check your details."}';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Logout failed');
    }
  }

  @override
  Future<UserModel?> registerWithEmailPassword(
    // Change return type
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        address: '',
        contactNumber: '',
        meterId: '',
        status: 'active',
        isAdmin: false,
      );

      await firestore
          .collection(userTablename)
          .doc(newUser.uid)
          .set(newUser.toMap());
      return newUser; // Returns UserModel
    } on FirebaseAuthException catch (e) {
      return null;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<String> sendResetPasswordEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return 'Password reset email sent! Check your inbox.';
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with that email.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        default:
          message = 'Password reset failed: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }
}
