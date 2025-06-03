import 'package:flutter/material.dart';

import '../screens/add_expense_screen.dart';

class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: FloatingActionButton(
        shape: CircleBorder(
          side: BorderSide(color: Colors.teal.shade700, width: 2),
        ),
        backgroundColor: Colors.teal.shade700,
        child: const Icon(Icons.add, size: 60, color: Colors.white),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTransactionScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt_outlined),
                    title: const Text('Ảnh chi tiêu'),
                    onTap: () {
                      Navigator.pop(context);
                      // Xử lý chụp ảnh ở đây nếu cần
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
