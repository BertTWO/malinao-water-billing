part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthUserPending extends AuthState {}

final class UserUnAuthenticated extends AuthState {}

final class Authenticated extends AuthState {
  final UserModel appUser;
  const Authenticated(this.appUser);

  @override
  List<Object> get props => [appUser];
}

final class UserAuthenticated extends AuthState {
  final UserModel appUser;
  const UserAuthenticated(this.appUser);

  @override
  List<Object> get props => [appUser];
}

final class UnAuthenticated extends AuthState {}

final class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

final class AuthUserRegistered extends AuthState {}
