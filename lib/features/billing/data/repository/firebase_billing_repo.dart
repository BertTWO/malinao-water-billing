// lib/features/billing/data/repositories/firebase_billing_repo.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malinaowaterbilling/core/constants/firebase_constants.dart';
import 'package:malinaowaterbilling/features/billing/domain/entity/repository/billing_repository.dart';
import 'package:malinaowaterbilling/features/billing/domain/entity/water_billing.dart';
import 'package:malinaowaterbilling/features/billing/domain/entity/payment.dart';

class FirebaseBillingRepo implements BillingRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String billsCollection = FirebaseConstants.waterBills;
  final String paymentsCollection = FirebaseConstants.payments;

  @override
  Future<void> createBill(WaterBillEntity bill) async {
    try {
      await firestore
          .collection(billsCollection)
          .doc(bill.id)
          .set(bill.toMap());
    } catch (e) {
      throw Exception('Failed to create bill: ${e.toString()}');
    }
  }

  @override
  Stream<List<WaterBillEntity>> getCustomerBills(String customerId) {
    return firestore
        .collection(billsCollection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WaterBillEntity.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<WaterBillEntity>> getAllBills() {
    return firestore
        .collection(billsCollection)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WaterBillEntity.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> updateBillStatus(String billId, String status) async {
    try {
      await firestore.collection(billsCollection).doc(billId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update bill status: ${e.toString()}');
    }
  }

  @override
  Future<void> recordPayment(PaymentEntity payment) async {
    try {
      await firestore.collection(paymentsCollection).add(payment.toMap());
      await updateBillStatus(payment.billId, 'paid');
    } catch (e) {
      throw Exception('Failed to record payment: ${e.toString()}');
    }
  }

  @override
  Future<double> getLastReading(String customerId) async {
    try {
      // FIXED: Use correct collection name from FirebaseConstants
      final query = await firestore
          .collection(
            billsCollection,
          ) // Changed from 'bills' to billsCollection
          .where('customerId', isEqualTo: customerId)
          .orderBy(
            'dueDate',
            descending: true,
          ) // Changed from 'billingDate' to 'dueDate'
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return 0.0; // No previous bills, starting fresh
      }

      final data = query.docs.first.data();
      return (data['currentReading'] as num).toDouble();
    } catch (e) {
      print("Error getting last reading: $e");
      return 0.0;
    }
  }

  @override
  Stream<List<PaymentEntity>> getCustomerPayments(String customerId) {
    return firestore
        .collection(paymentsCollection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PaymentEntity.fromMap(doc.data()))
              .toList(),
        );
  }
}
