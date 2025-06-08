// 의료기관 검색 화면에서 병원 카드 컴포넌트

import 'package:flutter/material.dart';
import '../../component/medical_facility.dart';

class MedicalFacilityCard extends StatelessWidget {
  final MedicalFacility facility;
  final String? distanceText;
  final VoidCallback onTap;

  const MedicalFacilityCard({
    required this.facility,
    required this.distanceText,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 1.0,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        title: Text(
          facility.getCleanDutyName() ?? '이름 없음',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(facility.dutyAddr ?? '주소 정보 없음'),
            Text('전화: ${facility.dutyTel1 ?? '정보 없음'}'),
            Row(
              children: [
                Text(
                  facility.todayOpenStatusFromServer ?? '운영 상태 정보 없음',
                  style: TextStyle(
                    color: facility.todayOpenStatusFromServer == '운영중'
                        ? Colors.green
                        : facility.todayOpenStatusFromServer == '운영종료'
                        ? Colors.red
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                if (distanceText != null)
                  Text(
                    distanceText!,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}