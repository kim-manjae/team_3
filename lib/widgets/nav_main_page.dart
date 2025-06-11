
import 'package:flutter/material.dart';
import 'package:project/chat_bot/chatbot_screen.dart';
import 'package:project/hospital/hospital_main.dart';
import 'package:project/profile/profile_screen.dart';
import 'package:project/reservation/reservation_list_page.dart';
import '../widgets/bottom_nav_bar.dart';


class nav_MainPage extends StatefulWidget {
  final int initialIndex;
  const nav_MainPage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _nav_MainPageState createState() => _nav_MainPageState();
}

class _nav_MainPageState extends State<nav_MainPage> {
  late int _currentIndex;

  @override
  void initState(){
    super.initState();
    _currentIndex = widget.initialIndex; // 초기값 설정
  }

  @override
  void didUpdateWidget(covariant nav_MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  final List<Widget> _pages = [
    HospitalMainPage(),
    ChatbotScreen(),
    ReservationListPage(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],                            // ② 인덱스에 따른 화면 전환
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentIndex,                          // ③ 현재 인덱스 지정
        onTap: (index) => setState(() => _currentIndex = index), // ② 탭 누르면 setState로 인덱스 변경
      ),
    );
  }
}
