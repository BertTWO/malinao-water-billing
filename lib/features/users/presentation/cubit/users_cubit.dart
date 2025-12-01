import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:malinaowaterbilling/features/users/domain/entity/user.dart';
import 'package:malinaowaterbilling/features/users/domain/repository/user_repo.dart';

part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  final UserRepo _usersRepo;

  UsersCubit(this._usersRepo) : super(UsersInitial());
  List<UserModel> customerLists = [];

  void getAllCustomers() {
    _usersRepo.getAllCustomers().listen((customers) {
      customerLists = customers;
      emit(UsersLoaded(customers));
    });
  }

  List<UserModel> getApprovedCustomersList() {
    return customerLists;
  }

  void getApprovedCustomers() {
    _usersRepo.getApprovedCustomers().listen((customers) {
      customerLists = customers; // Update customerLists
      emit(UsersLoaded(customers));
    });
  }

  // Get pending customers
  void getPendingCustomers() {
    _usersRepo.getPendingCustomers().listen((customers) {
      emit(UsersLoaded(customers));
    });
  }

  // Search customers
  void searchCustomers(String query) {
    if (query.isEmpty) {
      getAllCustomers();
    } else {
      _usersRepo.searchCustomers(query).listen((customers) {
        emit(UsersLoaded(customers));
      });
    }
  }

  // Create new customer
  void createCustomer({
    required String name,
    required String email,
    required String password,
    required String address,
    required String contactNumber,
    required String meterId,
    required bool isAdmin,
  }) async {
    emit(UsersLoading());
    try {
      await _usersRepo.createCustomer(
        name: name,
        email: email,
        password: password,
        address: address,
        contactNumber: contactNumber,
        meterId: meterId,
        isAdmin: isAdmin,
      );
      emit(UsersSuccess('Customer created successfully'));
      getAllCustomers();
    } catch (e) {
      emit(UsersError(e.toString()));
      getAllCustomers();
    }
  }

  // Update customer status (keeping this for backward compatibility)
  void updateCustomerStatus(String userId, String status) async {
    emit(UsersLoading());
    try {
      await _usersRepo.updateCustomerStatus(userId, status);
      emit(UsersSuccess('Customer status updated'));
      getAllCustomers();
    } catch (e) {
      emit(UsersError(e.toString()));
      getAllCustomers();
    }
  }

  // Update customer details
  void updateCustomer(UserModel customer) async {
    emit(UsersLoading());
    try {
      await _usersRepo.updateCustomer(customer);
      emit(UsersSuccess('Customer updated successfully'));
      getAllCustomers();
    } catch (e) {
      emit(UsersError(e.toString()));
      getAllCustomers();
    }
  }

  // Delete customer
  void deleteCustomer(String userId) async {
    emit(UsersLoading());
    try {
      await _usersRepo.deleteCustomer(userId);
      emit(UsersSuccess('Customer deleted successfully'));
      getAllCustomers();
    } catch (e) {
      emit(UsersError(e.toString()));
      getAllCustomers();
    }
  }
}
