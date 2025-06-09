import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/reservation_service.dart';
import '../services/auth_service.dart';

/// 예약 목록을 표시하는 페이지 위젯
///
/// 이 페이지는 사용자의 모든 예약 정보를 목록 형태로 보여줍니다.
/// 로그인하지 않은 사용자에게는 로그인 요청 화면을 표시하고,
/// 예약이 없는 경우 적절한 메시지를 표시합니다.
class ReservationListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 현재 저장된 모든 예약 정보를 가져옵니다
    final reservations = ReservationService.reservations;

    return Scaffold(
      appBar: AppBar(
        title: Text('reservation.status'.tr()),
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
                AuthService.login(); // 임시 로그인 처리
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservationListPage(),
                  ),
                );
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
                      builder: (context) => ReservationListPage(),
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