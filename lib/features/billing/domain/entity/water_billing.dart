// lib/features/billing/domain/entities/water_bill_entity.dart
class WaterBillEntity {
  final String id;
  final String customerId;
  final double currentReading;
  final double previousReading;
  final double amount;
  final String status; // "unpaid", "paid"
  final DateTime dueDate;

  const WaterBillEntity({
    required this.id,
    required this.customerId,
    required this.currentReading,
    required this.previousReading,
    required this.amount,
    required this.status,
    required this.dueDate,
  });

  double get consumption => currentReading - previousReading;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "customerId": customerId,
      "currentReading": currentReading,
      "previousReading": previousReading,
      "amount": amount,
      "status": status,
      "dueDate": dueDate.millisecondsSinceEpoch,
    };
  }

  factory WaterBillEntity.fromMap(Map<String, dynamic> map) {
    return WaterBillEntity(
      id: map["id"] ?? "",
      customerId: map["customerId"] ?? "",
      currentReading: (map["currentReading"] ?? 0).toDouble(),
      previousReading: (map["previousReading"] ?? 0).toDouble(),
      amount: (map["amount"] ?? 0).toDouble(),
      status: map["status"] ?? "unpaid",
      dueDate: DateTime.fromMillisecondsSinceEpoch(map["dueDate"]),
    );
  }
}
