import 'package:malinaowaterbilling/features/water_rates/domain/water_rates.dart';

abstract class WaterRatesRepo {
  // Get current water rate
  Future<WaterRateEntity?> getCurrentRate();

  Future<void> updateRate(double newRate);

  // Get rate history
  Stream<List<WaterRateEntity>> getRateHistory();
}
