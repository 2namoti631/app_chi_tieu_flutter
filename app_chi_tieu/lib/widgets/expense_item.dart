import 'package:app_chi_tieu/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class ExpenseItems extends StatelessWidget {
  const ExpenseItems({
    super.key,
    required this.expense,
  });

  final Expense expense;


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Color(0xFF51A563),  // Màu nền của biểu tượng
            borderRadius: BorderRadius.circular(16), // bo tròn các góc
          ),
          child: Icon(
            getCategoryIcon(expense.category),
            color: Colors.white, // Màu của biểu tượng
            size: 38, // Kích thước biểu tượng
          ),
        ),

        title: Text(expense.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            )),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(expense.date),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 18,
            )),

        trailing: Text(
          '${expense.amount} đ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'food':
        return Icons.fastfood;
      case 'phone':
        return Icons.phone_android;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_cart;
      default:
        return Icons.attach_money;
    }
  }
}