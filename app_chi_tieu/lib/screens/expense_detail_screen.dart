import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TransactionDetailScreen(),
  ));
}
class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          _buildCalendarBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: const [
                TransactionDayCard(
                  date: '24',
                  label: 'Hôm nay',
                  month: 'tháng 5 2025',
                  total: '-100,000',
                  items: [
                    TransactionItem(category: 'Ăn uống', note: 'ăn trưa', amount: '50,000'),
                    TransactionItem(category: 'Học tập', note: 'mua sách', amount: '50,000'),
                  ],
                ),
                SizedBox(height: 16),
                TransactionDayCard(
                  date: '23',
                  label: 'Hôm qua',
                  month: 'tháng 5 2025',
                  total: '-100,000',
                  items: [
                    TransactionItem(category: 'Sức khỏe', note: 'mua thuốc', amount: '60,000'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal.shade700,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.remove_circle_outline),
                    title: const Text('Thêm chi tiêu'),
                    onTap: () {
                      Navigator.pop(context);
                      // Điều hướng hoặc xử lý thêm chi tiêu
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text('Thêm thu nhập'),
                    onTap: () {
                      Navigator.pop(context);
                      // Điều hướng hoặc xử lý thêm thu nhập
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add, size: 32),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {},
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarBar() {
    final dates = ['19', '20', '21', '22', '23', '24', '25'];
    final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(dates.length, (index) {
            final isSelected = dates[index] == '24';
            return Column(
              children: [
                Text(dates[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    days[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
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
