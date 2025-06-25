import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;
import '../models/route_result.dart';
import 'dart:math';

class NavigationService {
  //네이버 클라우드 플랫폼 API 키
  static const String NAVER_CLIENT_ID = 'q884t9qoyu';
  static const String NAVER_CLIENT_SECRET = 'nYWOL1JM7AjZvZQvQWcdPKaxnwCs4MAz1qGcTQzw';

  //좌표에 가장 가까운 도로 위치를 반환
  static Future<NLatLng> findNearestRoad(NLatLng position) async {
    final url = Uri.parse(
        'https://maps.apigw.ntruss.com/map-reversegeocode/v2/gc'
            '?coords=${position.longitude},${position.latitude}'
            '&orders=roadaddr'
            '&output=json'
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'X-NCP-APIGW-API-KEY-ID': NAVER_CLIENT_ID,
          'X-NCP-APIGW-API-KEY': NAVER_CLIENT_SECRET,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          final result = results[0];

          //도로명 주소의 좌표 추출
          if (result['land'] != null && result['land']['addition0'] != null) {
            final coords = result['land']['addition0']['coords'];
            if (coords != null) {
              final coordParts = coords.toString().split(',');
              if (coordParts.length == 2) {
                try {
                  final longitude = double.parse(coordParts[0]);
                  final latitude = double.parse(coordParts[1]);

                  //좌표가 유효하면 반환
                  if (_isValidCoordinate(latitude, longitude)) {
                    print('Found nearest road coordinates: ($latitude, $longitude)');
                    return NLatLng(latitude, longitude);
                  }
                } catch (e) {
                  print('Error parsing coordinates: $e');
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('Geocoding Error: $e');
    }

    //실패 시 좌표를 약간 조정하여 반환
    print('Using slightly adjusted original coordinates');
    return _adjustCoordinate(position);
  }

  //위도, 경도의 유효성 검사
  static bool _isValidCoordinate(double latitude, double longitude) {
    //위도는 -90 ~ 90, 경도는 -180 ~ 180 범위 내에 있어야 함
    return latitude >= -90 && latitude <= 90 &&
        longitude >= -180 && longitude <= 180;
  }

  //좌표를 미세하게 조정(지도 API 오류 방지용)
  static NLatLng _adjustCoordinate(NLatLng position) {
    //약 5m 정도의 미세 조정
    const adjustment = 0.00005;
    return NLatLng(
        position.latitude + adjustment,
        position.longitude + adjustment
    );
  }

  //출발지와 목적지를 기반으로 경로 탐색 후 결과 반환
  static Future<RouteResult?> findRoute(NLatLng start, NLatLng destination) async {
    print('Original start: ${start.latitude}, ${start.longitude}');
    print('Original destination: ${destination.latitude}, ${destination.longitude}');

    //목적지 좌표가 비정상적으로 클 경우 정규화
    NLatLng adjustedDestination = destination;
    if (destination.latitude > 90 || destination.longitude > 180) {
      adjustedDestination = NLatLng(
          destination.latitude / 10000000,
          destination.longitude / 10000000
      );
      print('Normalized destination: ${adjustedDestination.latitude}, ${adjustedDestination.longitude}');
    }

    //출발지와 도착지의 가장 가까운 도로 위치 찾기
    final nearestStart = await findNearestRoad(start);
    final nearestDestination = await findNearestRoad(adjustedDestination);

    print('Adjusted start: ${nearestStart.latitude}, ${nearestStart.longitude}');
    print('Adjusted destination: ${nearestDestination.latitude}, ${nearestDestination.longitude}');

    //좌표 유효성 검사
    if (!_isValidCoordinate(nearestStart.latitude, nearestStart.longitude) ||
        !_isValidCoordinate(nearestDestination.latitude, nearestDestination.longitude)) {
      print('Invalid coordinates detected');
      return null;
    }

    //API에 전달할 문자열 형태의 좌표
    final startStr = "${nearestStart.longitude},${nearestStart.latitude}";
    final goalStr = "${nearestDestination.longitude},${nearestDestination.latitude}";

    //네이버 길찾기 API 호출(Directions 5사용)
    final url = Uri.parse(
        'https://maps.apigw.ntruss.com/map-direction/v1/driving'
            '?start=$startStr'
            '&goal=$goalStr'
            '&option=trafast'   //빠른길 우선 옵션
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'X-NCP-APIGW-API-KEY-ID': NAVER_CLIENT_ID,
          'X-NCP-APIGW-API-KEY': NAVER_CLIENT_SECRET,
        },
      );

      print('Direction API Response: ${response.statusCode}');
      print('Direction API URL: $url');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        //경로를 찾을 수 없는 경우 처리
        if (jsonResponse['code'] == 2) {
          print('Cannot find route: ${jsonResponse['message']}');
          return null;
        }

        final trafast = jsonResponse['route']?['trafast'] as List<dynamic>?;

        if (trafast == null || trafast.isEmpty) {
          print('No route found in response');
          return null;
        }

        final firstRoute = trafast[0];
        final path = firstRoute['path'] as List<dynamic>? ?? [];
        final summary = firstRoute['summary'] as Map<String, dynamic>?;

        if (summary == null) {
          print('No summary found in response');
          return null;
        }

        //소요 시간(ms 단위) 파싱
        int durationMilliseconds;
        final rawDuration = summary['duration'];
        if (rawDuration is int) {
          durationMilliseconds = rawDuration;
        } else if (rawDuration is String) {
          durationMilliseconds = int.tryParse(rawDuration) ?? 0;
        } else if (rawDuration is double) {
          durationMilliseconds = rawDuration.toInt();
        } else {
          durationMilliseconds = 0;
        }

        int durationSeconds = (durationMilliseconds / 1000).round();
        final distanceMeters = summary['distance'] is int ? summary['distance'] as int : 0;
        final distanceKm = (distanceMeters / 1000);

        //거리 및 소요 시간 문자열 생성
        String distanceStr = distanceKm < 1
            ? '${distanceMeters}m'
            : '${distanceKm.toStringAsFixed(2)}km';
        final hours = durationSeconds ~/ 3600;
        final minutes = (durationSeconds % 3600) ~/ 60;
        String durationStr = hours > 0
            ? '${hours}시간 ${minutes}분'
            : '${minutes}분';

        //경로 좌표 목록 생성
        final List<NLatLng> routeCoordinates = path
            .map((e) {
          final lat = e[1] as num;
          final lng = e[0] as num;
          return NLatLng(lat.toDouble(), lng.toDouble());
        }).toList();

        //경로가 원래 출발지/도착지와 멀리 떨어져 있을 경우 보정
        if (routeCoordinates.isNotEmpty) {
          final firstPathPoint = routeCoordinates.first;
          final lastPathPoint = routeCoordinates.last;

          //시작 지점 처리
          if (_calculateDistance(start, firstPathPoint) > 50) {
            routeCoordinates.insert(0, start);
          }

          //도착 지점 처리 - 조정된 목적지 좌표 사용
          if (_calculateDistance(adjustedDestination, lastPathPoint) > 50) {
            routeCoordinates.add(adjustedDestination);
          }
        }

        //경로 결과 반환
        return RouteResult(
            coordinates: routeCoordinates,
            distance: distanceStr,
            duration: durationStr
        );
      } else {
        print('API Error: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Navigation Error: $e');
      return null;
    }
  }

  //두 지점 간의 거리 계산 (미터 단위)
  static double _calculateDistance(NLatLng point1, NLatLng point2) {
    const double earthRadius = 6371000; //지구 반지름 (미터 단위)
    final double lat1 = point1.latitude * (pi / 180);
    final double lat2 = point2.latitude * (pi / 180);
    final double dLat = (point2.latitude - point1.latitude) * (pi / 180);
    final double dLon = (point2.longitude - point1.longitude) * (pi / 180);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  //경로 오버레이 생성(Naver Map 상에 경로 시각화)
  static NPathOverlay createPathOverlay(String id, List<NLatLng> coordinates) {
    return NPathOverlay(id: id, coords: coordinates)
      ..setColor(Colors.blue)             //경로 색상
      ..setWidth(6)                       //선 굵기
      ..setOutlineWidth(1)                //외곽선 두께
      ..setOutlineColor(Colors.white);    //외곽선 색상
  }
}