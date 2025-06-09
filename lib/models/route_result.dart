import 'package:flutter_naver_map/flutter_naver_map.dart';

//경로 탐색 결과를 담는 모델 클래스
class RouteResult {
  //경로를 구성하는 좌표 리스트 (지도에 표시할 경로선)
  final List<NLatLng> coordinates;
  //전체 거리
  final String distance;
  //전체 소요 시간
  final String duration;

  //생성자
  RouteResult({
    required this.coordinates,
    required this.distance,
    required this.duration,
  });
} 