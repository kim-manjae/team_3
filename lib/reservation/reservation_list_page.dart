import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:project/service/auth_service.dart';
import 'package:project/service/reservation_service.dart';
import 'package:project/widgets/language_dialog.dart';
import 'package:project/widgets/nav_main_page.dart';


/// 예약 목록을 표시하는 페이지 위젯
///
/// 이 페이지는 사용자의 모든 예약 정보를 목록 형태로 보여줍니다.
/// 로그인하지 않은 사용자에게는 로그인 요청 화면을 표시하고,
/// 예약이 없는 경우 적절한 메시지를 표시합니다.



class ReservationListPage extends StatelessWidget {

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 현재 저장된 모든 예약 정보를 가져옵니다
    final reservations = ReservationService.reservations;

    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => nav_MainPage(initialIndex: 0)),
                  (route) => false,
            );
          },
        ),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('reservation.status'.tr(),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () => _showLanguageDialog(context),
            tooltip: 'language_selection'.tr(),
          ),
        ],
      ),
      body: !AuthService.isLoggedIn
      // 로그인하지 않은 경우 로그인 요청 화면 표시
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('reservation.login_required'.tr()),
            SizedBox(height: 16),
            ElevatedButton(
               onPressed: () {
                   // 1) 로그인 상태를 true로 변경 (void 반환) :contentReference[oaicite:0]{index=0}
                   AuthService.login();

                   // 2) 로그인 성공 여부 확인
                   if (AuthService.isLoggedIn) {
                     // 3) 성공하면 예약 탭(index:2) 초기화된 메인 화면으로 교체
                     Navigator.pushReplacement(
                       context,
                       MaterialPageRoute(
                         builder: (_) => nav_MainPage(),
                       ),
                     );
                   } else {
                     // 4) 실패 시(이론상 없지만) 에러 안내
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('login_failed'.tr())),
                     );
                   }
                 },

              child: Text('login'.tr()),
            ),
          ],
        ),
      )
      // 예약이 없는 경우 안내 메시지 표시
          : reservations.isEmpty
          ? Center(
        child: Text('reservation.no_reservations'.tr()),
      )
      // 예약 목록 표시
          : ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              // 병원 이름 표시
              title: Text(reservation.hospitalName),
              // 병원 주소와 예약 일시 표시
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reservation.hospitalAddress),
                  Text(
                    '${reservation.reservationDate.toString().split(' ')[0]} ${reservation.reservationTime}',
                  ),
                ],
              ),
              // 예약 취소 버튼
              trailing: TextButton(
                onPressed: () {
                  ReservationService.removeReservation(reservation);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => nav_MainPage(initialIndex: 2),
                    ),
                  );
                },
                child: Text(
                  'reservation.cancel'.tr(),
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                // TODO: 병원 상세 정보 페이지로 이동
              },
            ),
          );
        },
      ),
    );
  }
}