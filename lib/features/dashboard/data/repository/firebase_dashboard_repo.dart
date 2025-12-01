import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:malinaowaterbilling/core/constants/firebase_constants.dart';
import 'package:malinaowaterbilling/features/dashboard/domain/repository/dashboard_repo.dart';

class FirebaseDashboardRepo implements DashboardRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<int> getTotalCustomers() async {
    try {
      final snapshot = await firestore
          .collection(FirebaseConstants.users)
          .where('isAdmin', isEqualTo: false)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get customers count: ${e.toString()}');
    }
  }

  @override
  Future<int> getPendingBills() async {
    try {
      final snapshot = await firestore
          .collection(FirebaseConstants.waterBills)
          .where('status', isEqualTo: 'unpaid')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get pending bills: ${e.toString()}');
    }
  }

  @override
  Future<int> getPaidBills() async {
    try {
      final snapshot = await firestore
          .collection(FirebaseConstants.waterBills)
          .where('status', isEqualTo: 'paid')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get paid bills: ${e.toString()}');
    }
  }

  @override
  Future<double> getTotalRevenue() async {
    try {
      final snapshot = await firestore
          .collection(FirebaseConstants.payments)
          .get();
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['amount'] ?? 0).toDouble();
      }
      return total;
    } catch (e) {
      throw Exception('Failed to get total revenue: ${e.toString()}');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getRecentActivity() {
    return firestore
        .collection(FirebaseConstants.payments)
        .orderBy('paymentDate', descending: true)
        .limit(10)
        .snapshots()
        .asyncMap((paymentSnapshot) async {
          final activities = <Map<String, dynamic>>[];

          for (var paymentDoc in paymentSnapshot.docs) {
            final paymentData = paymentDoc.data();
            final billDoc = await firestore
                .collection(FirebaseConstants.waterBills)
                .doc(paymentData['billId'])
                .get();

            if (billDoc.exists) {
              final billData = billDoc.data()!;
              final customerDoc = await firestore
                  .collection(FirebaseConstants.users)
                  .doc(billData['customerId'])
                  .get();

              if (customerDoc.exists) {
                activities.add({
                  'type': 'payment',
                  'customer': customerDoc.data()!['name'],
                  'action': 'Payment Received',
                  'amount': paymentData['amount'],
                  'time': paymentData['paymentDate'],
                  'customerData': customerDoc.data(),
                });
              }
            }
          }

          return activities;
        });
  }

  @override
  Future<List<Map<String, dynamic>>> getRevenueChartData() async {
    try {
      final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
      final snapshot = await firestore
          .collection(FirebaseConstants.payments)
          .where(
            'paymentDate',
            isGreaterThan: sixMonthsAgo.millisecondsSinceEpoch,
          )
          .get();

      // Group by month
      final Map<String, double> monthlyRevenue = {};
      for (var doc in snapshot.docs) {
        final paymentData = doc.data();
        final paymentDate = DateTime.fromMillisecondsSinceEpoch(
          paymentData['paymentDate'],
        );
        final monthKey = DateFormat('yyyy-MM').format(paymentDate);

        monthlyRevenue[monthKey] =
            (monthlyRevenue[monthKey] ?? 0) +
            (paymentData['amount'] ?? 0).toDouble();
      }

      // Convert to list and format
      final List<Map<String, dynamic>> chartData = monthlyRevenue.entries.map((
        entry,
      ) {
        final date = DateFormat('yyyy-MM').parse(entry.key);
        final formattedMonth = DateFormat('MMM yyyy').format(date);
        return {'month': formattedMonth, 'revenue': entry.value};
      }).toList();

      // Sort by date (oldest to newest for chart)
      chartData.sort(
        (a, b) => DateFormat(
          'MMM yyyy',
        ).parse(a['month']).compareTo(DateFormat('MMM yyyy').parse(b['month'])),
      );

      return chartData;
    } catch (e) {
      throw Exception('Failed to get revenue chart data: ${e.toString()}');
    }
  }
}
