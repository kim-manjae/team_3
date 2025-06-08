import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import '../component/medical_facility.dart';

class MedicalMapWidget extends StatelessWidget {
  final MedicalFacility facility;
  final Position? currentPosition;

  const MedicalMapWidget({
    required this.facility,
    this.currentPosition,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 4,
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(
              double.parse(facility.wgs84Lat ?? '37.5665'),
              double.parse(facility.wgs84Lon ?? '126.9780'),
            ),
            zoom: 15,
          ),
        ),
        onMapReady: (controller) {
          // 의료기관 마커 추가
          if (facility.wgs84Lat != null && facility.wgs84Lon != null) {
            final marker = NMarker(
              id: facility.hpid ?? '',
              position: NLatLng(
                double.parse(facility.wgs84Lat!),
                double.parse(facility.wgs84Lon!),
              ),
            );
            marker.setCaption(
              NOverlayCaption(
                text: facility.dutyName ?? '이름 없음',
                textSize: 14,
                // 운영 상태에 따라 마커 이름 색상 변경 (운영중: 검은색, 운영종료 등: 빨간색)
                color: facility.calculateTodayOpenStatus().contains('운영중') ? Colors.black : Colors.red,
              ),
            );
            controller.addOverlay(marker);
          }

          // 현재 위치 마커 추가
          if (currentPosition != null) {
            final currentMarker = NMarker(
              id: 'current_location',
              position: NLatLng(
                currentPosition!.latitude,
                currentPosition!.longitude,
              ),
            );
            currentMarker.setCaption(
              NOverlayCaption(
                text: '현재 위치',
                textSize: 14,
                color: Colors.blue,
              ),
            );
            controller.addOverlay(currentMarker);
          }
        },
      ),
    );
  }
}