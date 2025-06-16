import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:project/service/auth_service.dart';
import 'package:project/service/reservation_service.dart';
import 'package:project/widgets/language_dialog.dart';
import 'package:project/widgets/nav_main_page.dart';
import '../models/reservation.dart';
import 'reservation_list_page.dart';

/// 병원 예약 페이지 위젯
///
/// 이 페이지는 사용자가 특정 병원에 대한 예약을 생성할 수 있는 UI를 제공합니다.
/// 예약 가능한 날짜와 시간을 선택하고, 로그인 상태를 확인한 후 예약을 완료할 수 있습니다.
class HospitalReservationPage extends StatefulWidget {
  /// 예약할 병원의 이름
  final String hospitalName;

  /// 예약할 병원의 주소
  final String hospitalAddress;

  /// 병원의 영업 시작 시간 (HH:mm 형식)
  final String openTime;

  /// 병원의 영업 종료 시간 (HH:mm 형식)
  final String closeTime;

  const HospitalReservationPage({
    Key? key,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.openTime,
    required this.closeTime,
  }) : super(key: key);

  @override
  _HospitalReservationPageState createState() =>
      _HospitalReservationPageState();
}

class _HospitalReservationPageState extends State<HospitalReservationPage> {
  /// 선택된 예약 날짜
  DateTime selectedDate = DateTime.now();

  /// 선택된 예약 시간
  String? selectedTime;

  /// 예약 가능한 시간 목록
  List<String> availableTimes = [];

  // 언어 번역 기능
  void _showLanguageDialog() {
    showDialog(context: context, builder: (context) => const LanguageDialog());
  }

  @override
  void initState() {
    super.initState();
    _generateAvailableTimes();
  }

  /// 병원의 영업 시간을 기반으로 예약 가능한 시간 목록을 생성
  ///
  /// 영업 시작 시간부터 종료 시간 1시간 전까지 30분 간격으로 예약 가능한 시간을 생성합니다.
  void _generateAvailableTimes() {
    final openTime = TimeOfDay.fromDateTime(
      DateTime.parse('2024-01-01 ${widget.openTime}'),
    );
    final closeTime = TimeOfDay.fromDateTime(
      DateTime.parse('2024-01-01 ${widget.closeTime}'),
    );
    final endTime = TimeOfDay(
      hour: closeTime.hour - 1,
      minute: closeTime.minute,
    );

    availableTimes.clear();
    TimeOfDay currentTime = openTime;
    while (currentTime.hour < endTime.hour ||
        (currentTime.hour == endTime.hour &&
            currentTime.minute <= endTime.minute)) {
      availableTimes.add(
        '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}',
      );
      currentTime = TimeOfDay(
        hour: currentTime.hour + (currentTime.minute + 30) ~/ 60,
        minute: (currentTime.minute + 30) % 60,
      );
    }
  }

  /// 로그인이 필요한 경우 표시되는 다이얼로그
  ///
  /// 사용자가 로그인하지 않은 상태에서 예약을 시도할 때 호출됩니다.
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('login_required'.tr()),
            content: Text('login_to_reserve'.tr()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('cancel'.tr()),
              ),
              ElevatedButton(
                onPressed: () {
                  AuthService.login(); // 임시 로그인 처리
                  Navigator.pop(context);
                },
                child: Text('login'.tr()),
              ),
            ],
          ),
    );
  }

  /// 예약 확인 및 처리
  ///
  /// 로그인 상태를 확인하고, 선택된 시간이 있는 경우 예약을 생성합니다.
  /// 예약이 완료되면 예약 목록 페이지로 이동합니다.
  void _confirmReservation() {
    if (!AuthService.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    if (selectedTime == null) return;

    final reservation = Reservation(
      hospitalName: widget.hospitalName,
      hospitalAddress: widget.hospitalAddress,
      reservationDate: selectedDate,
      reservationTime: selectedTime!,
      userId: 'temp_user_id', // 임시 사용자 ID
    );

    ReservationService.addReservation(reservation);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nav_MainPage(initialIndex: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50, // 배경색 인데 맘에 안들면 없애기.
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'reservation.make'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: _showLanguageDialog,
            tooltip: 'language_selection'.tr(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 병원 정보 카드
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hospitalName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.hospitalAddress,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // 날짜 선택 섹션
            Text(
              'reservation.select_date'.tr(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Color(0xFF4BB8EA), //  선택된 날짜 색상
                  onPrimary: Colors.white, //  선택된 날짜의 텍스트 색상
                ),
              ),
              child: CalendarDatePicker(
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 30)),
                onDateChanged: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
            ),
            SizedBox(height: 10),
            // 시간 선택 섹션
            Text(
              'reservation.select_time'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children:
                  availableTimes.map((time) {
                    return ChoiceChip(
                      label: Text(
                        time,
                        style: TextStyle(
                          color:
                              selectedTime == time
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                      selected: selectedTime == time,
                      selectedColor: Color(0xFF4BB8EA),
                      checkmarkColor: Colors.white,
                      // backgroundColor: Colors.indigo.shade50,
                      onSelected: (selected) {
                        setState(() {
                          selectedTime = selected ? time : null;
                        });
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: 30),
            // 예약 확인 버튼
            Center(
              child: ElevatedButton(
                onPressed: selectedTime == null ? null : _confirmReservation,
                child: Text(
                  'reservation.confirm'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
