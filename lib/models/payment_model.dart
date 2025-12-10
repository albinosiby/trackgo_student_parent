class PaymentModel {
  final String id;
  final double amount;
  final String date;
  final String mode;
  final String referenceId;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.mode,
    required this.referenceId,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> data, String id) {
    return PaymentModel(
      id: id,
      amount: double.tryParse(data['amount']?.toString() ?? '0') ?? 0.0,
      date: data['date'] ?? '',
      mode: data['mode'] ?? 'Unknown',
      referenceId: data['reference_id'] ?? '',
    );
  }
}
