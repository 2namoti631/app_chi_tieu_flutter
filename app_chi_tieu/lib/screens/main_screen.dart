import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_chi_tieu/providers/user_provider.dart'; // đảm bảo đường dẫn đúng
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

    final userId = Provider.of<UserProvider>(context).userId;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
