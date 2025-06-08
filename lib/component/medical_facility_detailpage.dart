import 'package:flutter/material.dart';
import 'medical_facility.dart';
import '../map/medical_map.dart';

class MedicalFacilityDetailPage extends StatelessWidget {
  final MedicalFacility facility;

  const MedicalFacilityDetailPage({required this.facility, Key? key}) : super(key: key);

  // 시간을 'HHMM'에서 'HH:MM' 형식으로 변환 (Flutter 헬퍼 함수)
  String _formatTime(String? time) {
    if (time == null || time.isEmpty || time == "0000" || time == "정보없음") {
      return "정보 없음";
    }
    if (time.length == 4 && int.tryParse(time) != null) {
      return "${time.substring(0, 2)}:${time.substring(2, 4)}";
    }
    if (RegExp(r'^\d{2}:\d{2}$').hasMatch(time)) {
      return time;
    }
    return "정보 없음";
  }

  Map<String, String> getDutyTimes() {
    final Map<String, String> formattedTimes = {};
    void _addFormattedTime(String day, String? startTime, String? endTime) {
      String formattedStart = _formatTime(startTime);
      String formattedEnd = _formatTime(endTime);
      if (formattedStart == "정보 없음" && formattedEnd == "정보 없음") {
        formattedTimes[day] = "운영 시간 정보 없음";
      } else if (formattedStart != "정보 없음" && formattedEnd == "정보 없음") {
        formattedTimes[day] = "$formattedStart ~ 정보 없음";
      } else if (formattedStart == "정보 없음" && formattedEnd != "정보 없음") {
        formattedTimes[day] = "정보 없음 ~ $formattedEnd";
      } else {
        formattedTimes[day] = "$formattedStart ~ $formattedEnd";
      }
    }
    _addFormattedTime('월요일', facility.dutyTime1s, facility.dutyTime1c);
    _addFormattedTime('화요일', facility.dutyTime2s, facility.dutyTime2c);
    _addFormattedTime('수요일', facility.dutyTime3s, facility.dutyTime3c);
    _addFormattedTime('목요일', facility.dutyTime4s, facility.dutyTime4c);
    _addFormattedTime('금요일', facility.dutyTime5s, facility.dutyTime5c);
    _addFormattedTime('토요일', facility.dutyTime6s, facility.dutyTime6c);
    _addFormattedTime('일요일', facility.dutyTime7s, facility.dutyTime7c);
    _addFormattedTime('공휴일', facility.dutyTime8s, facility.dutyTime8c);
    return formattedTimes;
  }

  @override
  Widget build(BuildContext context) {
    final dutyTimes = getDutyTimes();
    final String calculatedStatus = facility.calculateTodayOpenStatus();
    final bool isOperating = calculatedStatus.contains('운영중');
    final String displayStatusText = calculatedStatus;
    final Color statusColor = isOperating ? Colors.green :
    calculatedStatus.contains('운영종료') ? Colors.red : Colors.grey;

    return Scaffold(
      appBar: AppBar(title: Text(facility.getCleanDutyName() ?? '상세 정보')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(facility.getCleanDutyName() ?? "정보 없음", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('주소: ${facility.dutyAddr ?? "정보 없음"}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('전화번호: ${facility.dutyTel1 ?? "정보 없음"}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text(
              '오늘 운영 상태',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 4),
            Text(
              displayStatusText,
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            SizedBox(height: 16),
            if (facility.wgs84Lat != null && facility.wgs84Lon != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('위치', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 8),
                  MedicalMapWidget(facility: facility),
                  SizedBox(height: 16),
                ],
              ),
            Text(
              '요일별 운영 시간',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              border: TableBorder.all(color: Colors.grey.shade300),
              children: dutyTimes.entries.map((e) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        e.key,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(e.value ?? '운영 시간 정보 없음'),
                    ),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            if (facility.dutyInf != null && facility.dutyInf!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('기관 설명:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 8),
                  Text(facility.dutyInf!, style: TextStyle(fontSize: 16)),
                ],
              ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}