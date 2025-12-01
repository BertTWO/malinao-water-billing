// lib/features/water_rates/domain/entities/water_rate_entity.dart
class WaterRateEntity {
  final double ratePerCubic;
  final DateTime updatedAt;

  const WaterRateEntity({required this.ratePerCubic, required this.updatedAt});

  Map<String, dynamic> toMap() {
    return {
      "ratePerCubic": ratePerCubic,
      "updatedAt": updatedAt.millisecondsSinceEpoch,
    };
  }

  factory WaterRateEntity.fromMap(Map<String, dynamic> map) {
    return WaterRateEntity(
      ratePerCubic: (map["ratePerCubic"] ?? 0).toDouble(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map["updatedAt"]),
    );
  }
}
