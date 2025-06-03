import 'package:app_chi_tieu/widgets/calender_bar.dart';
import 'package:flutter/material.dart';

import '../widgets/floating_button.dart';


class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key});
  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}
class _TransactionDetailScreenState extends State<TransactionDetailScreen> {

  DateTime selectedDate = DateTime.now();

  // Dữ liệu mẫu cho các giao dịch
  final List<Map<String, dynamic>> transactions = [
    {
      'date': DateTime(2025, 5, 24),
      'label': 'Hôm nay',
      'month': 'tháng 5 2025',
      'total': '-100,000',
      'items': [
        {'category': 'Ăn uống', 'note': 'ăn trưa', 'amount': '50,000'},
        {'category': 'Học tập', 'note': 'mua sách', 'amount': '50,000'},
      ],
    },
    {
      'date': DateTime(2025, 5, 23),
      'label': 'Hôm qua',
      'month': 'tháng 5 2025',
      'total': '-100,000',
      'items': [
        {'category': 'Sức khỏe', 'note': 'mua thuốc', 'amount': '60,000'},
      ],
    },
  ];


  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTransactions = transactions.where((tx) {
      return tx['date'].year == selectedDate.year &&
          tx['date'].month == selectedDate.month &&
          tx['date'].day == selectedDate.day;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Chi tiết giao dịch',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          CalendarPageBar(
            onDateSelected: (date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
              child: Text(
                'Không có giao dịch cho ngày ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                var tx = filteredTransactions[index];
                return TransactionDayCard(
                  date: tx['date'].day.toString(),
                  label: tx['label'],
                  month: tx['month'],
                  total: tx['total'],
                  items: (tx['items'] as List)
                      .map((item) => TransactionItem(
                    category: item['category'],
                    note: item['note'],
                    amount: item['amount'],
                  ))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton:CustomFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class TransactionDayCard extends StatelessWidget {
  final String date;
  final String label;
  final String month;
  final String total;
  final List<TransactionItem> items;

  const TransactionDayCard({
    super.key,
    required this.date,
    required this.label,
    required this.month,
    required this.total,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(date, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(month, style: const TextStyle(fontSize: 12)),
                ],
              ),
              const Spacer(),
              Text(
                total,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: item,
          )),
        ],
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String category;
  final String note;
  final String amount;

  const TransactionItem({
    super.key,
    required this.category,
    required this.note,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.red.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(note, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Icon(Icons.more_vert, size: 18),
        ],
      ),
    );
  }
}
