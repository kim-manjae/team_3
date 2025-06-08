// 의료기관 검색 화면 메인 페이지

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../pharmacy/pharmacy_find.dart';
import 'hospital_search_result_page.dart';


class HospitalMainPage extends StatefulWidget {
  @override
  _HospitalMainPageState createState() => _HospitalMainPageState();
}

class _HospitalMainPageState extends State<HospitalMainPage> {
  Position? currentPosition;

// 네이버 지도 초기화
  @override
  void initState() {
    super.initState();
    FlutterNaverMap().init(
      clientId: 'q884t9qoyu',
      onAuthFailed: (ex) => switch (ex) {
        NQuotaExceededException(:final message) =>
          print("사용량 초과 (message: $message)"),
        NUnauthorizedClientException() ||
        NClientUnspecifiedException() ||
        NAnotherAuthFailedException() =>
          print("인증 실패: $ex"),
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
            icon: const Icon(Icons.language, color: Colors.black87),
            onPressed: () {
              //언어 변경 로직
            },
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
                SizedBox(height: 20),
                Text(
                  '안녕하세요!',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                Text(
                  '병원 찾기 앱',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // 내 진료 기록 카드 또는 배너 추가 기능
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
                    children: const [
                      Text(
                        '내 진료 기록',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12),
                      Center(
                        child: Text(
                          '내 진료 기록이 없어요.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 병원 찾기, 약국 찾기 박스
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
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
                              // 병원명 또는 주소로 검색하세요.
        //                       SizedBox(height: 8),
        // Text(
        //   '병원명 또는 주소로\n검색하세요',
        //   textAlign: TextAlign.center,
        //   style: TextStyle(
        //     color: Colors.blue.shade700,
        //   ),
        // ),
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
                              // 현재 위치 기준 주변 약국을 찾아보세요.
        //                        SizedBox(height: 8),
        // Text(
        //   '현재 위치 기준\n주변 약국을 찾아보세요',
        //   textAlign: TextAlign.center,
        //   style: TextStyle(
        //     color: Colors.green.shade700,
        //   ),
        // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
          // mainAxisAlignment: MainAxisAlignment.center,
          // children: [
          //   // 병원 찾기 박스
          //   GestureDetector(
          //     onTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => HospitalSearchResultPage(
          //             currentPosition: currentPosition,
          //           ),
          //         ),
          //       );
          //     },
          //     child: Container(
          //       width: 180,
          //       height: 200,
          //       decoration: BoxDecoration(
          //         color: Colors.blue.shade50,
          //         borderRadius: BorderRadius.circular(20),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.grey.withOpacity(0.3),
          //             spreadRadius: 2,
          //             blurRadius: 5,
          //             offset: Offset(0, 3),
          //           ),
          //         ],
          //       ),
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Icon(
          //             Icons.local_hospital,
          //             size: 50,
          //             color: Colors.blue,
          //           ),
          //           SizedBox(height: 16),
          //           Text(
          //             '병원 찾기',
          //             style: TextStyle(
          //               fontSize: 20,
          //               fontWeight: FontWeight.bold,
          //               color: Colors.blue,
          //             ),
          //           ),
          //           SizedBox(height: 8),
          //           Text(
          //             '병원명 또는 주소로\n검색하세요',
          //             textAlign: TextAlign.center,
          //             style: TextStyle(
          //               color: Colors.blue.shade700,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          //   SizedBox(width: 20),
          //   // 내 주변 약국 찾기 박스
          //   GestureDetector(
          //     onTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => PharmacyFindPage(),
          //         ),
          //       );
          //     },
          //     child: Container(
          //       width: 180,
          //       height: 200,
          //       decoration: BoxDecoration(
          //         color: Colors.green.shade50,
          //         borderRadius: BorderRadius.circular(20),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.grey.withOpacity(0.3),
          //             spreadRadius: 2,
          //             blurRadius: 5,
          //             offset: Offset(0, 3),
          //           ),
          //         ],
          //       ),
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Icon(
          //             Icons.local_pharmacy,
          //             size: 50,
          //             color: Colors.green,
          //           ),
          //           SizedBox(height: 16),
          //           Text(
          //             '내 주변 약국 찾기',
          //             style: TextStyle(
          //               fontSize: 20,
          //               fontWeight: FontWeight.bold,
          //               color: Colors.green,
          //             ),
          //           ),
          //           SizedBox(height: 8),
          //           Text(
          //             '현재 위치 기준\n주변 약국을 찾아보세요',
          //             textAlign: TextAlign.center,
          //             style: TextStyle(
          //               color: Colors.green.shade700,
          //             ),
          //           ),
          //         ],
          //       )
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  // }
// }