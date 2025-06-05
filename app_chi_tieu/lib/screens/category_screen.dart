import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<CategoryScreen> {
  List categories = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    print("HomeScreen loaded");
  }

  Future<void> fetchCategories() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/categories/$userId'), // ví dụ API lấy danh mục theo userId
    );

    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
        loading = false;
        print('Response body: ${response.body}');
      });
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lấy dữ liệu thất bại')),
      );
    }
  }
  Future<void> updateCategory(String category_id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8080/categories/$category_id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      fetchCategories(); // cập nhật lại danh sách
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại')),
      );
    }
  }
  Future<void> deleteCategory(String cat_id) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8080/categories/$cat_id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa thành công')),
      );
      fetchCategories(); // Refresh lại danh sách
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa thất bại')),
      );
    }
  }
  void _confirmDelete(String cat_id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteCategory(cat_id);

            },
            child: Text('Xóa'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map category) {
    TextEditingController nameController = TextEditingController(text: category['name']);
    TextEditingController iconController = TextEditingController(text: category['icon']);
    TextEditingController colorController = TextEditingController(text: category['color']);
    String selectedType = category['type'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Sửa danh mục'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Tên'),
                  ),
                  TextField(
                    controller: iconController,
                    decoration: InputDecoration(labelText: 'Icon'),
                  ),
                  TextField(
                    controller: colorController,
                    decoration: InputDecoration(labelText: 'Màu (hex)'),
                  ),
                  DropdownButton<String>(
                    value: selectedType,
                    items: ['income', 'expense']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedType = value!;
                      });
                    },
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    updateCategory(category['_id'], {
                      'name': nameController.text,
                      'icon': iconController.text,
                      'color': colorController.text,
                      'type': selectedType,
                    });
                  },
                  child: Text('Lưu'),
                )
              ],
            );
          },
        );
      },
    );
  }
  Future<void> createCategory(Map<String, dynamic> data) async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/categories/'), // API POST để tạo mới
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        ...data,
        'user_id': userId,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo danh mục thành công')),
      );
      fetchCategories(); // làm mới lại danh sách
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo danh mục thất bại')),
      );
    }
  }
  void _showCreateDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController iconController = TextEditingController();
    String selectedType = 'expense';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Tạo danh mục mới'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Tên'),
                  ),
                  TextField(
                    controller: iconController,
                    decoration: InputDecoration(labelText: 'Icon'),
                  ),
                  DropdownButton<String>(
                    value: selectedType,
                    items: ['income', 'expense']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedType = value!;
                      });
                    },
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    createCategory({
                      'name': nameController.text,
                      'icon': iconController.text,
                      'type': selectedType,
                    });
                  },
                  child: Text('Tạo'),
                )
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Trang Categories'),
      actions: [
        IconButton(onPressed: _showCreateDialog ,
            icon: Icon(Icons.add)),
      ],),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (_, index) {
          return ListTile(
            leading: Text(categories[index]['icon'], style: TextStyle(fontSize: 24)),
            title: Text(categories[index]['name'] ?? 'No name'),
            subtitle: Text(categories[index]['type'] ?? ''),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 18),
              onSelected: (String value) {
                if (value == 'edit') {
                  _showEditDialog(categories[index]);
                } else if (value == 'delete') {
                  _confirmDelete(categories[index]['_id'], categories[index]['name']);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Sửa'),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Xóa'),
                ),
              ],
            ),


          );
        },
      ),
    );
  }
}
