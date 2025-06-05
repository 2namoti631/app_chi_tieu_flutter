import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../models/transaction_item_model.dart';
import '../providers/user_provider.dart';
import '../widgets/category_bar_chart.dart';
import '../widgets/floating_button.dart';


// ... giữ nguyên phần import và các class model/provider/widget

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedFilter = 'Month';
  double totalSpent = 0;
  List<TransactionItemModel> expenseItems = [];
  List<CategoryExpense> categoryExpensesList = [];

  @override
  void initState() {
    super.initState();
    loadAnalyticsData(selectedFilter);
  }

  Map<String, double> aggregateByCategory(List<TransactionItemModel> items) {
    final Map<String, double> result = {};
    for (var item in items) {
      final cat = item.category ?? 'Khác';
      final amount = item.amount ?? 0;
      result[cat] = (result[cat] ?? 0) + amount;
    }
    return result;
  }

  Future<void> loadAnalyticsData(String filter) async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final uri = Uri.parse("http://10.0.2.2:8080/analytics/").replace(queryParameters: {
      "user_id": userId,
      "filter_by": filter.toLowerCase(),
      "reference_date": DateTime.now().toIso8601String(),
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<TransactionItemModel> loadedItems = [];

        for (var transaction in data['transactions']) {
          final date = transaction['date'];
          for (var item in transaction['items'] ?? []) {
            loadedItems.add(TransactionItemModel.fromJson({
              ...item,
              'date': date,
              'userId': userId,
            }));
          }
        }

        final categoryTotals = aggregateByCategory(loadedItems);
        final categoryExpenses = categoryTotals.entries
            .map((e) => CategoryExpense(category: e.key, totalAmount: e.value))
            .toList();

        setState(() {
          totalSpent = (data['total_spent'] ?? 0).toDouble();
          expenseItems = loadedItems;
          categoryExpensesList = categoryExpenses;
        });
      } else {
        print("Lỗi khi gọi API: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi gọi API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  '📊 Analytics',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['Week', 'Month', 'Year']
                    .map((label) => _timeFilterButton(label))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Text(
                      '${totalSpent.toStringAsFixed(2)} VND',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                    const Text(
                      'Tổng chi tiêu',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 250,
                  child: CategoryBarChart(data: categoryExpensesList),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                '📌 Thống kê theo danh mục',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(thickness: 1.2),
              categoryExpensesList.isEmpty
                  ? const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Center(
                  child: Text('Chưa có dữ liệu chi tiêu',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
                  : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categoryExpensesList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final item = categoryExpensesList[index];
                  return CategoryExpenseCard(
                    category: item.category,
                    amount: item.totalAmount,
                  );
                },
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
      floatingActionButton: const CustomFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _timeFilterButton(String label) {
    final isSelected = label == selectedFilter;
    return GestureDetector(
      onTap: () {
        setState(() => selectedFilter = label);
        loadAnalyticsData(label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.grey[300],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class CategoryExpenseCard extends StatelessWidget {
  final String category;
  final double amount;

  const CategoryExpenseCard({
    super.key,
    required this.category,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.category, color: Colors.teal),
        title: Text(
          category,
          style: const TextStyle(
            fontWeight: FontWeight.w600, // in đậm hơn chút
            fontSize: 18,               // tăng font size lên 18
          ),
        ),
        trailing: Text(
          '${amount.toStringAsFixed(2)} VND',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,               // tăng font size lên 18
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

