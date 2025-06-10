import 'package:flutter/material.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home),              label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: '챗봇'),
        BottomNavigationBarItem(icon: Icon(Icons.history),           label: '진료기록'),
        BottomNavigationBarItem(icon: Icon(Icons.person),            label: '내정보'),
      ],
    );
  }
}