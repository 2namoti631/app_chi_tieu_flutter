import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../models/category_model.dart';
import '../models/transaction_item_model.dart';
import '../providers/user_provider.dart';
import 'expense_item.dart';
import 'home_header.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  List<TransactionItemModel> transactions = [];
  List<Category> categoryList = [];
  bool isLoading = true;
  String? errorMessage;

  /// Tính tổng số tiền đã chi tiêu trong ngày hôm nay
  double getTodayTotal() {
    final today = DateTime.now();
    return transactions.where((tx) {
      final date = tx.date;
      if (date == null) return false;
      return date.year == today.year && date.month == today.month && date.day == today.day;
    }).fold(0.0, (sum, tx) => sum + (tx.amount ?? 0));
  }

  Future<void> fetchCategories(String userId) async {
    final url = 'http://10.0.2.2:8080/categories/$userId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      final loadedCategories = data.map((e) => Category.fromJson(e)).toList();

      setState(() {
        categoryList = loadedCategories;
      });
      await fetchRecentTransactions();
    } else {
      throw Exception("Lỗi khi tải danh mục");
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId != null) {
        fetchCategories(userId);
      }
    });
  }

  Future<void> fetchRecentTransactions() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final url = 'http://10.0.2.2:8080/transactions/user/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        List<TransactionItemModel> loadedTransactions = [];

        for (var transaction in data) {
          if (transaction['items'] != null) {
            for (var item in transaction['items']) {
              loadedTransactions.add(TransactionItemModel.fromJson({
                ...item,
                'date': transaction['date'],
                'userId': transaction['user_id'],
              }));
            }
          }
        }
        loadedTransactions.sort((a, b) {
          final dateA = a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
          final dateB = b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
          return dateB.compareTo(dateA);
        });

        setState(() {
          transactions = loadedTransactions;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Lỗi server: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi kết nối: $e';
        isLoading = false;
      });
    }
  }

  String getIconForCategory(String categoryName) {
    final match = categoryList.firstWhere(
          (cat) => cat.name == categoryName,
      orElse: () => Category(id: '', userId: '', name: categoryName, icon: '❓', type: ''),
    );
    return match.icon;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    final todayTotal = getTodayTotal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeHeader(todayTotal: todayTotal), // <-- đây là header tính tổng hôm nay
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Chi Tiêu Gần Đây',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(color: Colors.grey, thickness: 1),
        Expanded(
          child: transactions.isEmpty
              ? const Center(
            child: Text(
              'Không có giao dịch gần đây.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: transactions.take(4).length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final icon = getIconForCategory(tx.category);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    tx.category ?? 'Danh mục không xác định',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Ngày: ${tx.date != null ? DateFormat('dd/MM/yyyy').format(tx.date!) : 'Không xác định'}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Text(
                    '\$${tx.amount?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}