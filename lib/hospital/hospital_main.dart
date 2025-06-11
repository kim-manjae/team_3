// 의료기관 검색 화면 메인 페이지

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project/chat_bot/chatbot_screen.dart';
import '../pharmacy/pharmacy_find.dart';
import 'hospital_search_result_page.dart';
import 'package:easy_localization/easy_localization.dart';
import '../emergency/emergency_box.dart';
import '../emergency/emergency_map_page.dart';

class HospitalMainPage extends StatefulWidget {
  @override
  _HospitalMainPageState createState() => _HospitalMainPageState();
}

class _HospitalMainPageState extends State<HospitalMainPage> {
  Position? currentPosition;

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('language_selection'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('korean'.tr()),
                onTap: () {
                  context.setLocale(const Locale('ko'));
                  Navigator.pop(context);
                },
                trailing:
                    context.locale.languageCode == 'ko'
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
              ),
              ListTile(
                title: Text('english'.tr()),
                onTap: () {
                  context.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
                trailing:
                    context.locale.languageCode == 'en'
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
              ),
              ListTile(
                title: Text('japanese'.tr()),
                onTap: () {
                  context.setLocale(const Locale('ja'));
                  Navigator.pop(context);
                },
                trailing:
                    context.locale.languageCode == 'ja'
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: _showLanguageDialog,
            tooltip: 'language_selection'.tr(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  '안녕하세요.',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const Text(
                  '병원 찾기 앱 입니다.',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.blue.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '뭘 넣을까요',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12),
                      Center(
                        child: Text(
                          '여기에 글자 말고 배너?',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                //병원 및 약국 찾기
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => HospitalSearchResultPage(
                                    currentPosition: currentPosition,
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          height: 140,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_hospital,
                                size: 48,
                                color: Colors.blue,
                              ),
                              SizedBox(height: 12),
                              Text(
                                '병원 찾기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PharmacyFindPage(),
                            ),
                          );
                        },
                        child: Container(
                          height: 140,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_pharmacy,
                                size: 48,
                                color: Colors.blue,
                              ),
                              SizedBox(height: 12),
                              Text(
                                '약국 찾기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatbotScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emergency, color: Colors.red, size: 24),
                        SizedBox(width: 12),
                        Text(
                          '응급 병원 찾기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
