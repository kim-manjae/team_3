/// 위치 관련 기능을 제공하는 서비스 클래스
///
/// 이 클래스는 다음과 같은 기능을 제공합니다:
/// - 현재 위치 조회
/// - 위치 권한 관리
/// - 좌표를 주소로 변환 (구현 예정)
///
/// Geolocator와 Naver Map API를 사용하여 구현되어 있습니다.

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class LocationService {
  /// 현재 위치를 조회하는 메서드
  ///
  /// 위치 권한을 확인하고, 위치 서비스가 활성화되어 있는지 확인한 후
  /// 현재 위치를 반환합니다.
  ///
  /// Returns: 현재 위치의 위도와 경도를 포함한 NLatLng 객체
  ///          권한이 없거나 위치 서비스가 비활성화된 경우 null 반환
  static Future<NLatLng?> getCurrentLocation() async {
    try {
      // 위치 권한 요청 및 확인
      final status = await Permission.location.request();
      if (!status.isGranted) {
        print('Location permission denied');
        return null;
      }

      // 위치 서비스 활성화 상태 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      // 현재 위치 조회 (높은 정확도로 설정)
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Naver Map 좌표 객체로 변환하여 반환
      return NLatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// 좌표를 주소로 변환하는 메서드
  ///
  /// 현재는 임시로 좌표값을 문자열로 반환합니다.
  /// 추후 네이버 Geocoding API를 사용하여 실제 주소로 변환하도록 구현 예정입니다.
  ///
  /// [latLng] 변환할 위도/경도 좌표
  /// Returns: 좌표에 해당하는 주소 문자열
  static Future<String> getAddressFromLatLng(NLatLng latLng) async {
    // TODO: Implement address lookup using Naver Geocoding API
    return '${latLng.latitude}, ${latLng.longitude}';
  }
}