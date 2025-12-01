import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:malinaowaterbilling/features/billing/domain/entity/payment.dart';
import 'package:malinaowaterbilling/features/billing/domain/entity/repository/billing_repository.dart';
import 'package:malinaowaterbilling/features/billing/domain/entity/water_billing.dart';

part 'billing_state.dart';

class BillingCubit extends Cubit<BillingState> {
  final BillingRepo _billingRepo;

  BillingCubit(this._billingRepo) : super(BillingInitial());

  // Create new bill
  void createBill(WaterBillEntity bill) async {
    emit(BillingLoading());
    try {
      await _billingRepo.createBill(bill);
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<double> getLastReadingForCustomer(String customerId) async {
    return await _billingRepo.getLastReading(customerId);
  }

  // Get all bills
  void getAllBills() {
    _billingRepo.getAllBills().listen((bills) {
      emit(BillsLoaded(bills));
    });
  }

  // Get customer bills
  void getCustomerBills(String customerId) {
    _billingRepo.getCustomerBills(customerId).listen((bills) {
      emit(BillsLoaded(bills));
    });
  }

  // Record payment
  void recordPayment(PaymentEntity payment) async {
    emit(BillingLoading());
    try {
      await _billingRepo.recordPayment(payment);
      emit(BillingSuccess('Payment recorded successfully'));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  // Get customer payments
  void getCustomerPayments(String customerId) {
    _billingRepo.getCustomerPayments(customerId).listen((payments) {
      emit(PaymentsLoaded(payments));
    });
  }
}
