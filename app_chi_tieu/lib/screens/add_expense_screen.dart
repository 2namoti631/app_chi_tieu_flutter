import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final List<String> categories = [
  'Ăn uống',
  'Đi lại',
  'Mua sắm',
  'Giải trí',
  'Học tập',
  'Y tế',
];
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

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
                  onPressed: () {
                    // TODO: xử lý lưu dữ liệu
                    print("Tiền: ${amountController.text}");
                    print("Danh mục: ${categoryController.text}");
                    print("Ngày: ${dateController.text}");
                    print("Ghi chú: ${noteController.text}");
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
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
          child: Icon(icon, color: Colors.black,size: 35,),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                builder: (_) => ListView(
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
                  color: controller.text.isEmpty ? Colors.black54 : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

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
          radius:35,
          backgroundColor: color,
          child: Icon(icon, color: Colors.black, size: 35,),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                String formattedDate =
                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";

                // Cập nhật giá trị text và giao diện
                setState(() {
                  controller.text = formattedDate;
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
                  color:
                  controller.text.isEmpty ? Colors.black54 : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}
