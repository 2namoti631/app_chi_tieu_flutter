import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_item_model.dart';

class TransactionItem extends StatelessWidget {
  final TransactionItemModel item;

  const TransactionItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = item.date != null
        ? DateFormat('yyyy-MM-dd').format(item.date!)
        : 'N/A';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.pink[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_mapCategoryToIcon(item.category), size: 28, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(dateFormatted, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Text(
            '\$${item.amount}',
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  IconData _mapCategoryToIcon(String label) {
    switch (label.toLowerCase()) {
      case 'ăn uống':
        return Icons.fastfood;
      case 'học tập':
        return Icons.menu_book;
      case 'giải trí':
        return Icons.movie;
      default:
        return Icons.attach_money;
    }
  }
}
