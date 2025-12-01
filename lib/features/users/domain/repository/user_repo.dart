import 'package:malinaowaterbilling/features/users/domain/entity/user.dart';

abstract class UserRepo {
  Stream<List<UserModel>> getAllCustomers();
  Stream<List<UserModel>> getPendingCustomers();
  Stream<List<UserModel>> getApprovedCustomers();
  Stream<List<UserModel>> searchCustomers(String query);

  Future<void> createCustomer({
    required String name,
    required String email,
    required String password,
    required String address,
    required String contactNumber,
    required String meterId,
    required bool isAdmin,
  });

  Future<void> updateCustomerStatus(String userId, String status);
  Future<void> updateCustomer(UserModel customer);
  Future<void> deleteCustomer(String userId);
}
