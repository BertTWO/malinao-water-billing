import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malinaowaterbilling/features/auth/domain/repository/auth_repo.dart';
import 'package:malinaowaterbilling/features/users/domain/entity/user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  UserModel? _currentUser;

  AuthCubit(this.authRepo) : super(AuthInitial());

  UserModel? get currentUser => _currentUser;

  void checkAuth() async {
    if (state is Authenticated ||
        state is UserAuthenticated ||
        state is AuthLoading)
      return;

    emit(AuthLoading());
    try {
      final userModel = await authRepo.getCurrentAccount();

      if (userModel != null) {
        _currentUser = userModel;

        // FIXED: Check if admin or customer and emit appropriate state
        if (userModel.isAdmin) {
          emit(Authenticated(userModel));
        } else {
          emit(UserAuthenticated(userModel));
        }
      } else {
        emit(UnAuthenticated());
      }
    } catch (ex) {
      emit(AuthError(ex.toString()));
      Future.delayed(Duration.zero, () {
        if (state is AuthError) {
          emit(UnAuthenticated());
        }
      });
    }
  }

  Future<void> login(String email, String pw) async {
    emit(AuthLoading());
    try {
      final userModel = await authRepo.loginWithEmailPassword(email, pw);
      if (userModel != null) {
        _currentUser = userModel;

        if (userModel.isAdmin) {
          emit(Authenticated(userModel));
        } else {
          emit(UserAuthenticated(userModel));
        }
      } else {
        emit(UnAuthenticated());
      }
    } catch (ex) {
      emit(AuthError(ex.toString()));
      Future.delayed(const Duration(milliseconds: 100), () {
        emit(UnAuthenticated());
      });
    }
  }

  Future<void> register(String name, String email, String pw) async {
    emit(AuthLoading());
    try {
      final UserModel? appUser = await authRepo.registerWithEmailPassword(
        name,
        email,
        pw,
      );

      if (appUser != null) {
        _currentUser = appUser;
        emit(AuthUserRegistered());
      } else {
        emit(AuthError('Registration failed'));
        Future.delayed(const Duration(milliseconds: 100), () {
          emit(UnAuthenticated());
        });
      }
    } catch (ex) {
      emit(AuthError(ex.toString()));
      Future.delayed(const Duration(milliseconds: 100), () {
        if (state is AuthError) {
          emit(UnAuthenticated());
        }
      });
    }
  }

  Future<void> logout() async {
    try {
      emit(AuthLoading());
      await authRepo.logout();
      _currentUser = null;
      emit(UnAuthenticated());
    } catch (ex) {
      emit(AuthError(ex.toString()));
      Future.delayed(const Duration(milliseconds: 100), () {
        emit(UnAuthenticated());
      });
    }
  }
}

// auth_state.dart (part of 'auth_cubit.dart')
// No changes needed to the states
