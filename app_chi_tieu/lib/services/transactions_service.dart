import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<List<Map<String, dynamic>>> fetchTransactionsFromApi(DateTime date, String userId) async {
  final formattedDate = DateFormat('yyyy-MM-dd').format(date);
  final uri = Uri.parse('http://10.0.2.2:8080/transactions/?user_id=$userId&date=$formattedDate');
  print("Fetching transactions for user_id=$userId & date=$formattedDate");
  print("URL: $uri");

  final response = await http.get(uri);
  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));

  } else {
    throw Exception('Failed to load transactions');
  }
}

Future<void> deleteTransaction(int transactionId) async {
  final response = await http.delete(
    Uri.parse('http://10.0.2.2:8080/transactions/$transactionId'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete transaction');
  }
}

Future<void> updateTransaction(int transactionId, Map<String, dynamic> data) async {
  final response = await http.put(
    Uri.parse('http://10.0.2.2:8080/transactions/$transactionId'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update transaction');
  }
}