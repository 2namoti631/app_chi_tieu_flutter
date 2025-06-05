import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/category_model.dart';

// Ví dụ lấy danh sách categories
Future<List<Category>> fetchCategories(String userId) async {
  final response = await http.get(
    Uri.parse('http://10.0.2.2:8080/categories/$userId'),
  );

  if (response.statusCode == 200) {
    List jsonData = json.decode(response.body);
    return jsonData.map((cat) => Category.fromJson(cat)).toList();
  } else {
    throw Exception('Failed to load categories');
  }
}
