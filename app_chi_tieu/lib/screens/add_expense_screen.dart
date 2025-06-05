import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {

  List<String> categories = [];

  Future<void> fetchCategories() async {
    final userId = Provider
        .of<UserProvider>(context, listen: false)
        .userId;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/categories/$userId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          categories = data.map((e) => e['name'] as String).toList();
        });
      } else {
        print("Lỗi lấy danh mục: ${response.body}");
      }
    } catch (e) {
      print("Lỗi kết nối danh mục: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  bool loading = false;

  Future<void> createTransaction(BuildContext context) async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    try {
      setState(() {
        loading = true;
      });

      final amount = int.tryParse(amountController.text) ?? 0;
      final date = dateController.text;
      final category = categoryController.text;
      final note = noteController.text;

      final data = {
        "user_id": userId,
        "date": selectedDate != null
            ? "${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
            : DateTime.now().toIso8601String().split('T').first,
        "items": [
          {
            "amount": amount,
            "type": "expense",
            "category": category,
            "note": note,
          }
        ]
      };


      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/transactions/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tạo giao dịch thành công")),
        );
        Navigator.pop(context);
      } else {
        print("Lỗi tạo giao dịch: ${response.statusCode}");
        print("Chi tiết: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${response.body}")),
        );
      }
    } catch (e) {
      print("Lỗi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề + nút đóng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thêm giao dịch',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 35),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 90),

            // Ô nhập số tiền
            buildInputRow(
              icon: Icons.account_balance_wallet,
              color: Colors.greenAccent,
              hint: 'Nhập số tiền..',
              controller: amountController,
              isNumber: true,
            ),

            const SizedBox(height: 16),

            // Danh mục chi tiêu
            buildCategoryPicker(
              icon: Icons.category,
              color: Colors.greenAccent,
              hint: 'Danh mục chi tiêu...',
              controller: categoryController,
              categories: categories,
              context: context,
            ),

            const SizedBox(height: 16),

            // Ngày
            buildDatePicker(
              icon: Icons.calendar_today,
              color: Colors.greenAccent,
              hint: 'Chọn ngày',
              controller: dateController,
              context: context,
            ),


            const SizedBox(height: 16),

            // Ghi chú
            buildInputRow(
              icon: Icons.notes,
              color: Colors.greenAccent,
              hint: 'Ghi chú',
              controller: noteController,
              isNumber: false,
            ),

            const Spacer(),

            // Nút Save
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: loading
                      ? null
                      : () {
                    createTransaction(context);
                  },
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Save',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildInputRow({
    required IconData icon,
    required Color color,
    required String hint,
    bool isNumber = false,
    TextEditingController? controller,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: color,
          child: Icon(icon, color: Colors.black, size: 35,),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            inputFormatters: isNumber
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              fillColor: Colors.grey.shade300,
              filled: true,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }


  Widget buildCategoryPicker({
    required IconData icon,
    required Color color,
    required String hint,
    required TextEditingController controller,
    required List<String> categories,
    required BuildContext context,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: color,
          child: Icon(icon, color: Colors.black, size: 35),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (_) =>
                    ListView(
                      children: categories.map((category) {
                        return ListTile(
                          title: Text(category),
                          onTap: () {
                            controller.text = category;
                            Navigator.pop(context);
                            setState(() {}); // cập nhật giao diện
                          },
                        );
                      }).toList(),
                    ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              height: 50,
              alignment: Alignment.centerLeft,
              child: Text(
                controller.text.isEmpty ? hint : controller.text,
                style: TextStyle(
                  color: controller.text.isEmpty ? Colors.black54 : Colors
                      .black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  DateTime? selectedDate;

  Widget buildDatePicker({
    required IconData icon,
    required Color color,
    required String hint,
    required TextEditingController controller,
    required BuildContext context,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: color,
          child: Icon(icon, color: Colors.black, size: 35),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                  controller.text =
                  "${picked.day}/${picked.month}/${picked.year}";
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              height: 50,
              alignment: Alignment.centerLeft,
              child: Text(
                controller.text.isEmpty ? hint : controller.text,
                style: TextStyle(
                  color: controller.text.isEmpty ? Colors.black54 : Colors
                      .black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}