import 'package:flutter/material.dart';
import '../models/transaction_item_model.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionItemModel tx;
  final String icon;

  const TransactionListItem({super.key, required this.tx, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey.shade200,
          child: Text(icon, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(
          tx.category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tx.date != null ? tx.date!.toLocal().toString().split(' ')[0] : ''),

            if (tx.note.isNotEmpty) Text(tx.note),
          ],
        ),
        trailing: Text(
          '- \$${tx.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
