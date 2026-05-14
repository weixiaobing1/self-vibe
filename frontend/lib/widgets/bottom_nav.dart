import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '首页'),
        BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), label: '知识库'),
        BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'AI'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: '统计'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outlined), label: '我的'),
      ],
    );
  }
}