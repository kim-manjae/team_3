import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class LocationService {
  //위치 권한 체크 및 현재 위치 가져오기
  static Future<NLatLng?> getCurrentLocation() async {
    try {
      //위치 권한 요청
      final status = await Permission.location.request();
      if (!status.isGranted) {
        print('Location permission denied');
        return null;
      }

      //위치 서비스가 활성화되어 있는지 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      //현재 위치 가져오기
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return NLatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  //좌표를 주소로 변환하는 메서드 (이 부분은 네이버 Geocoding API를 사용하도록 구현 필요)
  static Future<String> getAddressFromLatLng(NLatLng latLng) async {
    // TODO: Implement address lookup using Naver Geocoding API
    return '${latLng.latitude}, ${latLng.longitude}';
  }
}