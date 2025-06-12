// 의료기관 검색 화면 메인 페이지

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../pharmacy/pharmacy_find.dart';
import '../reservation/reservation_list_page.dart';
import '../widgets/nav_main_page.dart';
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
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text('메인 화면',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87),),
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
                SizedBox(height: 10),
                // Container(
                //   width: double.infinity,
                //   padding: const EdgeInsets.all(20),
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       colors: [Colors.blue.shade50, Colors.blue.shade100],
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //     ),
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         '뭘 넣을까요',
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.black87,
                //         ),
                //       ),
                //       SizedBox(height: 8),
                //       Center(
                //         child: Text(
                //           '여기에 글자 말고 배너?',
                //           style: TextStyle(fontSize: 13, color: Colors.black87),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 20),

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
                                  (context) => HospitalSearchResultPage(),
                            ),
                          );
                        },
                          child: Container(
                              width: double.infinity,
                              height: 200,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.blueAccent.shade100,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.local_hospital,
                                    size: 100,
                                    color: Colors.blueAccent.shade700,
                                  ),
                                  SizedBox(height: 0),
                                  Text(
                                    '병원 찾기',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      ),
                    SizedBox(width: 16),
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
                        // child: PolygonOverlay(
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blueAccent.shade100,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_pharmacy,
                                size: 100,
                                color: Colors.blueAccent.shade700,
                              ),
                              SizedBox(height: 0),
                              Text(
                                '약국 찾기',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ),
                      ),
                    // ),
                  ],
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                    builder: (context) => nav_MainPage(initialIndex: 1),
                  ),
                    );
                  },

                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blueAccent.shade100,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/aidoc_logo.png',
                              width: 100,    // 아이콘 크기 대신 너비
                              height: 100,   // 높이 지정
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '챗봇으로 대화하기',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '챗봇으로 대화를 해보세요. \n길찾기부터 병원까지 한번에!',
                                      style: TextStyle(fontSize: 13, color: Colors.black54),
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EmergencyMapPage()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '응급 병원 찾기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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


/// 2) 반투명 폴리곤을 오버레이하는 CustomPainter
class PolygonOverlay extends StatelessWidget {
  final Widget child;

  const PolygonOverlay({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(child: CustomPaint(painter: _PolygonPainter())),
      ],
    );
  }
}

class _PolygonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white10.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final path =
        Path()
          ..moveTo(size.width * 0.2, size.height * 0.1)
          ..lineTo(size.width * 0.8, size.height * 0.25)
          ..lineTo(size.width * 0.5, size.height * 0.6)
          ..close();

    canvas.drawPath(path, paint);
    // 더 많은 폴리곤을 그리고 싶으면 여기 추가
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
