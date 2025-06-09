import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'emergency_model.dart';

class EmergencyService {
  // localhost 대신 실제 서버 IP 주소 사용
  static const String baseUrl = 'http://10.0.2.2:8000/api/emergency/search';  // Android 에뮬레이터용
  // static const String baseUrl = 'http://127.0.0.1:8000/api/emergency/search';  // iOS 시뮬레이터용

  // 거리를 km 단위로 변환하는 함수
  static String formatDistance(double? meters) {
    if (meters == null) return '-';
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
    return '${meters.toStringAsFixed(0)}m';
  }

  static Future<List<EmergencyFacility>> fetchNearbyEmergency({
    required String stage1,
    required String stage2,
    required double latitude,
    required double longitude,
    int radius = 5000,
  }) async {
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'STAGE1': stage1,
        'STAGE2': stage2,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
        'num_of_rows': '50',
      });

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('서버 연결 시간이 초과되었습니다.');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List items = data['items'] ?? [];

        // 디버깅을 위한 상세 로그 출력
        print('API Response Data:');
        print('Total items: ${items.length}');
        if (items.isNotEmpty) {
          print('First item raw data: ${json.encode(items.first)}');
        }

        String? getStringValue(Map<String, dynamic> json, String key) {
          return json[key] ?? json[key.toLowerCase()];
        }
        return items.map((e) {
          String? hpid = getStringValue(e, 'hpid');
          String? name = getStringValue(e, 'dutyName');
          String? tel = getStringValue(e, 'dutyTel');
          String? addr = getStringValue(e, 'dutyAddr');
          String? lat = getStringValue(e, 'wgs84Lat');
          String? lon = getStringValue(e, 'wgs84Lon');
          String? subject = getStringValue(e, 'dgidIdName');
          double? distance;
          if (e['distance'] != null) {
            distance = double.tryParse(e['distance'].toString());
          }
          if (name == null || tel == null || lat == null || lon == null) {
            print('Missing required information for facility:');
            print('Raw data: ${json.encode(e)}');
            print('HPID: $hpid');
            print('Name: $name');
            print('Tel: $tel');
            print('Coordinates: $lat, $lon');
          }
          return EmergencyFacility(
            hpid: hpid,
            dutyName: name,
            dutyTel: tel,
            dutyAddr: addr,
            wgs84Lat: lat,
            wgs84Lon: lon,
            dgidIdName: subject,
            distance: distance,
          );
        })
            .where((facility) =>
        facility.dutyName != null && facility.dutyName!.isNotEmpty &&
            facility.dutyTel != null && facility.dutyTel!.isNotEmpty &&
            facility.dutyAddr != null && facility.dutyAddr!.isNotEmpty &&
            facility.wgs84Lat != null && facility.wgs84Lat!.isNotEmpty &&
            facility.wgs84Lon != null && facility.wgs84Lon!.isNotEmpty
        )
            .toList();
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('서버 연결 시간이 초과되었습니다.');
    } on SocketException {
      throw Exception('서버에 연결할 수 없습니다. 인터넷 연결을 확인해주세요.');
    } catch (e) {
      throw Exception('응급의료기관 정보를 불러오지 못했습니다: $e');
    }
  }
}