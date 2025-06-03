import 'package:flutter/material.dart';
import 'package:app_chi_tieu/screens/analytics_screen.dart';
import 'package:app_chi_tieu/screens/home_screen.dart';
import '../widgets/bottom_navigator.dart';
import 'expense_detail_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    TransactionDetailScreen(),
    AnalyticsScreen(),
  ];
  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],  // Hiển thị màn hình tương ứng tab
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}