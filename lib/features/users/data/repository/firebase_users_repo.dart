import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:malinaowaterbilling/core/constants/firebase_constants.dart';
import 'package:malinaowaterbilling/features/users/domain/entity/user.dart';
import 'package:malinaowaterbilling/features/users/domain/repository/user_repo.dart';

class FirebaseUsersRepo implements UserRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final String usersCollection = FirebaseConstants.users;

  @override
  Stream<List<UserModel>> getAllCustomers() {
    return firestore
        .collection(usersCollection)
        .where('isAdmin', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<UserModel>> getPendingCustomers() {
    return firestore
        .collection(usersCollection)
        .where('status', isEqualTo: 'pending')
        .where('isAdmin', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<UserModel>> getApprovedCustomers() {
    return firestore
        .collection(usersCollection)
        .where('isAdmin', isEqualTo: false)
        .where(
          'status',
          isEqualTo: 'active',
        ) // Changed from 'approved' to 'active'
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<UserModel>> searchCustomers(String query) {
    return firestore
        .collection(usersCollection)
        .where('isAdmin', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .where(
                (user) =>
                    user.name.toLowerCase().contains(query.toLowerCase()) ||
                    user.meterId.toLowerCase().contains(query.toLowerCase()) ||
                    user.email.toLowerCase().contains(query.toLowerCase()),
              )
              .toList(),
        );
  }

  @override
  Future<void> createCustomer({
    required String name,
    required String email,
    required String password,
    required String address,
    required String contactNumber,
    required String meterId,
    required bool isAdmin,
  }) async {
    try {
      // Create user in Firebase Authentication
      final UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final String uid = userCredential.user!.uid;

      // Create customer document in Firestore
      final UserModel newCustomer = UserModel(
        uid: uid,
        name: name,
        email: email,
        address: address,
        contactNumber: contactNumber,
        meterId: meterId,
        status: 'active', // Changed from 'approved' to 'active'
        isAdmin: isAdmin,
      );

      await firestore
          .collection(usersCollection)
          .doc(uid)
          .set(newCustomer.toMap());

      // Sign out the newly created user to keep admin signed in
      await auth.signOut();
    } catch (e) {
      throw Exception('Failed to create customer: ${e.toString()}');
    }
  }

  @override
  Future<void> updateCustomerStatus(String userId, String status) async {
    try {
      await firestore.collection(usersCollection).doc(userId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update customer status: ${e.toString()}');
    }
  }

  @override
  Future<void> updateCustomer(UserModel customer) async {
    try {
      await firestore
          .collection(usersCollection)
          .doc(customer.uid)
          .update(customer.toMap());
    } catch (e) {
      throw Exception('Failed to update customer: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCustomer(String userId) async {
    try {
      // Delete from Firestore
      await firestore.collection(usersCollection).doc(userId).delete();

      // Note: Deleting from Firebase Auth requires the user to be signed in
      // You may want to implement a Cloud Function for this
      // or use Firebase Admin SDK on the backend
    } catch (e) {
      throw Exception('Failed to delete customer: ${e.toString()}');
    }
  }
}
