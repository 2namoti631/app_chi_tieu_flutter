class TransactionItemModel {
  final int amount;
  final String type;
  final String category;
  final String note;
  final DateTime? date;  // ← sửa từ String? thành DateTime?
  final String? userId;

  TransactionItemModel({
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    this.date,
    this.userId,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      amount: json['amount'] ?? 0,
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      note: json['note'] ?? '',
      // Parse string → DateTime
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      userId: json['userId'],
    );
  }

  // Nếu bạn cần gửi lại lên server:
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'type': type,
      'category': category,
      'note': note,
      'date': date?.toIso8601String(),  // ← chuyển ngược lại
      'userId': userId,
    };
  }
}
