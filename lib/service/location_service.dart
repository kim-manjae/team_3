import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';

class LocationService {
  /// 위치 권한 요청 → 서비스 활성화 확인 → 현재 위치 반환
  /// 권한 거부나 서비스 비활성화 시 예외를 던집니다.
  static Future<Position> getCurrentPosition() async {
    // 1) 권한 요청
    final status = await Permission.location.request();
    if (!status.isGranted) {
      throw Exception('location_permission_denied'.tr());
    }

    // 2) 위치 서비스 활성화 확인
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('location_service_disabled'.tr());
    }

    // 3) 현재 위치 획득 (수초 소요될 수 있음)
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}