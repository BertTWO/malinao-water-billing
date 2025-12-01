// lib/features/billing/presentation/cubit/billing_state.dart
part of 'billing_cubit.dart';

sealed class BillingState extends Equatable {
  const BillingState();

  @override
  List<Object?> get props => [];
}

class BillingInitial extends BillingState {}

class BillingLoading extends BillingState {}

class BillingSuccess extends BillingState {
  final String message;
  const BillingSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class BillsLoaded extends BillingState {
  final List<WaterBillEntity> bills;
  const BillsLoaded(this.bills);

  @override
  List<Object?> get props => [bills];
}

class PaymentsLoaded extends BillingState {
  final List<PaymentEntity> payments;
  const PaymentsLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

class BillingError extends BillingState {
  final String message;
  const BillingError(this.message);

  @override
  List<Object?> get props => [message];
}
