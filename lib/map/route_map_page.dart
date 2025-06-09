import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../models/route_result.dart';
import '../component/medical_facility.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class RouteMapPage extends StatefulWidget {
  final RouteResult routeResult;
  final MedicalFacility destination;

  const RouteMapPage({required this.routeResult, required this.destination, Key? key}) : super(key: key);

  @override
  State<RouteMapPage> createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage> {
  NaverMapController? _mapController;
  StreamSubscription<Position>? _positionStream;
  NMarker? _myLocationMarker;
  bool _isNavigating = false;
  bool _arrived = false;

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  void _startNavigation() async {
    if (_isNavigating) return;
    setState(() { _isNavigating = true; });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('길 안내를 시작합니다')),
    );
    // 위치 권한 확인 및 스트림 구독
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((position) async {
      final latLng = NLatLng(position.latitude, position.longitude);
      // 내 위치 마커 없으면 생성, 있으면 위치만 갱신
      if (_myLocationMarker == null) {
        _myLocationMarker = NMarker(id: 'my_location', position: latLng);
        _myLocationMarker!.setCaption(NOverlayCaption(text: '내 위치', textSize: 14, color: Colors.blue));
        await _mapController?.addOverlay(_myLocationMarker!);
      } else {
        _myLocationMarker!.setPosition(latLng);
      }
      // 카메라 따라가기(옵션)
      await _mapController?.updateCamera(
        NCameraUpdate.withParams(target: latLng, zoom: 16),
      );
      // 목적지 도착 체크(50m 이내)
      final dest = widget.routeResult.coordinates.isNotEmpty
          ? widget.routeResult.coordinates.last
          : NLatLng(0, 0);
      final distance = _calculateDistance(latLng, dest);
      if (!_arrived && distance < 50) {
        setState(() { _arrived = true; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('목적지에 도착했습니다!')),
        );
        _positionStream?.cancel();
      }
    });
  }

  double _calculateDistance(NLatLng a, NLatLng b) {
    const double earthRadius = 6371000;
    final dLat = (b.latitude - a.latitude) * (3.141592653589793 / 180.0);
    final dLon = (b.longitude - a.longitude) * (3.141592653589793 / 180.0);
    final lat1 = a.latitude * (3.141592653589793 / 180.0);
    final lat2 = b.latitude * (3.141592653589793 / 180.0);
    final aVal = (sin(dLat / 2) * sin(dLat / 2)) +
        (sin(dLon / 2) * sin(dLon / 2)) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(aVal), sqrt(1 - aVal));
    return earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('경로 안내')),
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: widget.routeResult.coordinates.isNotEmpty
                    ? widget.routeResult.coordinates.first
                    : NLatLng(37.5665, 126.9780),
                zoom: 14,
              ),
            ),
            onMapReady: (controller) async {
              _mapController = controller;
              // 경로 Polyline
              final pathOverlay = NPathOverlay(
                id: 'route_path',
                coords: widget.routeResult.coordinates,
                color: Colors.blue,
                width: 6,
              );
              controller.addOverlay(pathOverlay);
              // 목적지 마커
              final marker = NMarker(
                id: 'destination',
                position: widget.routeResult.coordinates.isNotEmpty
                    ? widget.routeResult.coordinates.last
                    : NLatLng(37.5665, 126.9780),
              );
              marker.setCaption(NOverlayCaption(
                text: widget.destination.dutyName ?? '목적지',
                textSize: 14,
                color: Colors.red,
              ));
              controller.addOverlay(marker);
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white.withOpacity(0.95),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.destination.dutyName ?? '목적지'}까지\n거리: ${widget.routeResult.distance}, 예상 소요: ${widget.routeResult.duration}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.navigation),
                      label: Text(_isNavigating ? '안내 중...' : '길 안내'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isNavigating ? Colors.grey : Colors.green,
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isNavigating ? null : _startNavigation,
                    ),
                  ),
                  if (_arrived)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('목적지에 도착했습니다!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}