import 'package:malinaowaterbilling/features/billing/domain/entity/water_billing.dart';
import 'package:malinaowaterbilling/features/billing/domain/entity/payment.dart';

abstract class BillingRepo {
  Future<void> createBill(WaterBillEntity bill);

  Stream<List<WaterBillEntity>> getCustomerBills(String customerId);

  Stream<List<WaterBillEntity>> getAllBills();

  Future<void> updateBillStatus(String billId, String status);

  Future<void> recordPayment(PaymentEntity payment);
  Stream<List<PaymentEntity>> getCustomerPayments(String customerId);
  Future<double> getLastReading(String customerId);
}
