// 의료기관 검색 화면 메인 페이지

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../pharmacy/pharmacy_find.dart';
import '../reservation/reservation_list_page.dart';
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
                trailing: context.locale.languageCode == 'ko' ? Icon(Icons.check, color: Colors.green) : null,
              ),
              ListTile(
                title: Text('english'.tr()),
                onTap: () {
                  context.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
                trailing: context.locale.languageCode == 'en' ? Icon(Icons.check, color: Colors.green) : null,
              ),
              ListTile(
                title: Text('japanese'.tr()),
                onTap: () {
                  context.setLocale(const Locale('ja'));
                  Navigator.pop(context);
                },
                trailing: context.locale.languageCode == 'ja' ? Icon(Icons.check, color: Colors.green) : null,
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
        title: Text('medical_search'.tr()),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: _showLanguageDialog,
            tooltip: 'language_selection'.tr(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 병원 찾기 박스
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HospitalSearchResultPage(
                          currentPosition: currentPosition,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 180,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_hospital,
                          size: 50,
                          color: Colors.blue,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'find_hospital'.tr(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'search_hint'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20),
                // 내 주변 약국 찾기 박스
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PharmacyFindPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: 180,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_pharmacy,
                          size: 50,
                          color: Colors.green,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'find_pharmacy'.tr(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'search_by_location'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            // 내 주변 응급의료기관 찾기 박스
            EmergencyBox(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmergencyMapPage(),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            // 예약 현황 버튼
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservationListPage(),
                  ),
                );
              },
              child: Container(
                width: 180,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 30,
                      color: Colors.purple,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'reservation.status'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

