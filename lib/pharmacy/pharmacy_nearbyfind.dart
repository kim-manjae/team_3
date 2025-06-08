import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import '../component/medical_facility.dart';
import '../component/medical_facility_detailpage.dart';
import '../hospital/hospital_search.dart' show MedicalFacilityDetailPage;

class NearbyMedicalMapWidget extends StatefulWidget {
  final Position currentPosition;
  final List<MedicalFacility> facilities;
  final String title;

  const NearbyMedicalMapWidget({
    required this.currentPosition,
    required this.facilities,
    this.title = '주변 약국',
    Key? key,
  }) : super(key: key);

  @override
  _NearbyMedicalMapWidgetState createState() => _NearbyMedicalMapWidgetState();
}

class _NearbyMedicalMapWidgetState extends State<NearbyMedicalMapWidget> {
  NaverMapController? _mapController;
  final double _radius = 500; // 500m 반경
  bool _isListVisible = false; // 약국 목록 표시 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.green),
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(
                  widget.currentPosition.latitude,
                  widget.currentPosition.longitude,
                ),
                zoom: 14, // 500m 반경이 잘 보이도록 줌 레벨 설정 (필요에 따라 조정, 15가 적절할 수 있습니다)
              ),
              scrollGesturesEnable: true,
              zoomGesturesEnable: true,
              tiltGesturesEnable: true,
              rotationGesturesEnable: true,
              stopGesturesEnable: true,
              locationButtonEnable: true,
            ),
            onMapReady: (controller) {
              _mapController = controller;

              // 현재 위치 마커 추가
              final currentMarker = NMarker(
                id: 'current_location',
                position: NLatLng(
                  widget.currentPosition.latitude,
                  widget.currentPosition.longitude,
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

              // 반경 원 추가
              final circle = NCircleOverlay(
                id: 'radius_circle',
                center: NLatLng(
                  widget.currentPosition.latitude,
                  widget.currentPosition.longitude,
                ),
                radius: _radius,
                color: Colors.green.withOpacity(0.1),
                outlineColor: Colors.green,
                outlineWidth: 2,
              );
              controller.addOverlay(circle);

              // 약국 마커 추가
              for (var facility in widget.facilities) {
                if (facility.wgs84Lat != null && facility.wgs84Lon != null) {
                  final marker = NMarker(
                    id: facility.hpid ?? '',
                    position: NLatLng(
                      double.parse(facility.wgs84Lat!),
                      double.parse(facility.wgs84Lon!),
                    ),
                  );

                  // 마커 캡션 색상 조건부 표시 -> 항상 검은색으로 변경
                  // calculateTodayOpenStatus 결과를 가져와서 마커 이미지 결정에 사용
                  final String calculatedStatus =
                  facility.calculateTodayOpenStatus();
                  final bool isOperating = calculatedStatus.contains('운영중');

                  marker.setCaption(
                    NOverlayCaption(
                      text: facility.getCleanDutyName() ?? '이름 없음',
                      textSize: 14,
                      // 약국 이름은 항상 검은색으로 표시
                      color: Colors.black,
                    ),
                  );
                  marker.setOnTapListener((overlay) {
                    // <-- 이 부분이 추가되었습니다.
                    // 마커 탭 시 상세 정보 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                            MedicalFacilityDetailPage(facility: facility),
                      ),
                    );
                  });
                  controller.addOverlay(marker);
                }
              }
            },
          ),

          // 하단에 약국 목록 표시
          if (_isListVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '주변 약국 목록',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.facilities.length,
                        itemBuilder: (context, index) {
                          final facility = widget.facilities[index];
                          // MedicalFacility 모델의 계산된 운영 상태 사용
                          final String calculatedStatus =
                          facility.calculateTodayOpenStatus();
                          final bool isOperating = calculatedStatus.contains(
                            '운영중',
                          );

                          // 운영 상태에 따라 색상 변경
                          final Color statusColor =
                          isOperating
                              ? Colors.green
                              : calculatedStatus.contains('운영종료')
                              ? Colors.red
                              : Colors.grey; // 정보 없음 등

                          return ListTile(
                            leading: Icon(
                              Icons.local_pharmacy,
                              color: statusColor, // 계산된 상태에 따라 아이콘 색상 변경
                            ),
                            title: Text(
                              facility.getCleanDutyName() ?? '이름 없음',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(facility.dutyAddr ?? '주소 없음'),
                            trailing: Text(
                              calculatedStatus, // 계산된 상태 텍스트 표시
                              style: TextStyle(
                                color: statusColor, // 계산된 상태에 따라 텍스트 색상 변경
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => MedicalFacilityDetailPage(
                                    facility: facility,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 목록 보기/숨기기 버튼
          Positioned(
            bottom: _isListVisible ? 216.0 : 16.0,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    _isListVisible = !_isListVisible;
                  });
                },
                label: Text(_isListVisible ? '지도 보기' : '목록 보기'),
                icon: Icon(_isListVisible ? Icons.map : Icons.list),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}