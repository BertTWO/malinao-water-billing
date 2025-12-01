import 'package:malinaowaterbilling/features/users/domain/entity/user.dart';

abstract class AuthRepo {
  Future<UserModel?> loginWithEmailPassword(String email, String password);
  Future<UserModel?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  );
  Future<void> logout();
  Future<UserModel?> getCurrentAccount();
  Future<void> deleteAccount();
  Future<String> sendResetPasswordEmail(String email);
}
