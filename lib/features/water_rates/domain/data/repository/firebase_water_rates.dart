// lib/features/water_rates/data/repositories/firebase_water_rates_repo.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malinaowaterbilling/core/constants/firebase_constants.dart';
import 'package:malinaowaterbilling/features/water_rates/domain/repository/water_rates_repo.dart';
import 'package:malinaowaterbilling/features/water_rates/domain/water_rates.dart';

class FirebaseWaterRatesRepo implements WaterRatesRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String ratesCollection = FirebaseConstants.waterRates;

  @override
  Future<WaterRateEntity?> getCurrentRate() async {
    try {
      final snapshot = await firestore
          .collection(ratesCollection)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final data = snapshot.docs.first.data();
      return WaterRateEntity.fromMap(data);
    } catch (e) {
      throw Exception('Failed to get water rate: ${e.toString()}');
    }
  }

  @override
  Future<void> updateRate(double newRate) async {
    try {
      final newRateEntity = WaterRateEntity(
        ratePerCubic: newRate,
        updatedAt: DateTime.now(),
      );

      await firestore.collection(ratesCollection).add(newRateEntity.toMap());
    } catch (e) {
      throw Exception('Failed to update water rate: ${e.toString()}');
    }
  }

  @override
  Stream<List<WaterRateEntity>> getRateHistory() {
    return firestore
        .collection(ratesCollection)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WaterRateEntity.fromMap(doc.data()))
              .toList(),
        );
  }
}
