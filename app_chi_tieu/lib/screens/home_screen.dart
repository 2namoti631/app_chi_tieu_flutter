import 'package:flutter/material.dart';
import 'package:app_chi_tieu/widgets/home_body.dart';
import 'package:app_chi_tieu/widgets/home_header.dart';
import '../widgets/floating_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 33),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 20),
              Homeheader(),
              SizedBox(height: 20),
              Expanded(child: HomeBody()),
            ],
          ),
        ),
      ),
      floatingActionButton:CustomFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
