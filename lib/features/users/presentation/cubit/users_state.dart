// lib/features/users/presentation/cubit/users_state.dart
part of 'users_cubit.dart';

sealed class UsersState extends Equatable {
  const UsersState();
  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<UserModel> customers;
  const UsersLoaded(this.customers);

  @override
  List<Object?> get props => [customers];
}

class UsersSuccess extends UsersState {
  final String message;
  const UsersSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UsersError extends UsersState {
  final String message;
  const UsersError(this.message);

  @override
  List<Object?> get props => [message];
}
