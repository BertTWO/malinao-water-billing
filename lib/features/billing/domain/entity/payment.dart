// lib/features/billing/domain/entities/payment_entity.dart
class PaymentEntity {
  final String billId;
  final double amount;
  final DateTime paymentDate;

  const PaymentEntity({
    required this.billId,
    required this.amount,
    required this.paymentDate,
  });

  Map<String, dynamic> toMap() {
    return {
      "billId": billId,
      "amount": amount,
      "paymentDate": paymentDate.millisecondsSinceEpoch,
    };
  }

  factory PaymentEntity.fromMap(Map<String, dynamic> map) {
    return PaymentEntity(
      billId: map["billId"] ?? "",
      amount: (map["amount"] ?? 0).toDouble(),
      paymentDate: DateTime.fromMillisecondsSinceEpoch(map["paymentDate"]),
    );
  }
}
