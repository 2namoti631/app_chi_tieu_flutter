import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense_model.dart';
import 'expense_item.dart';

// Dữ liệu mẫu recentExpenses
final List<Expense> recentExpenses = [
  Expense(
    title: 'Ăn trưa',
    amount: 50000,
    date: DateTime.now(),
    category: 'food',
  ),
  Expense(
    title: 'Mua sách',
    amount: 150000,
    date: DateTime.now().subtract(Duration(days: 1)),
    category: 'education',
  ),
];


class HomeBody extends StatelessWidget {
  const HomeBody({super.key});


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // canh trái cho title
      children: [
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Text(
              'Chi Tiêu Gần Đây',
              style: TextStyle(
                color: Color(0xFF000000),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Divider(
          color: Colors.grey,
          thickness: 1,
        ),
        // Sử dụng Expanded để ListView có chiều cao cố định trong Column
        Expanded(
          child: ListView.builder(
            itemCount: recentExpenses.length,
            itemBuilder: (context, index) {
              return ExpenseItems(expense: recentExpenses[index]);
            },
          ),
        ),
      ],
    );
  }

}


