class TransactionModel {
  final int? id;
  final String appName;
  final String amount;
  final DateTime timestamp;

  TransactionModel({
    this.id,
    required this.appName,
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'app_name': appName,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      appName: map['app_name'],
      amount: map['amount'],
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
