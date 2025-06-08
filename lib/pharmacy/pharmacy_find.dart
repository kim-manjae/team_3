import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:xml/xml.dart';
import 'dart:math' show cos, sqrt, asin;
import '../component/medical_facility.dart';
import 'pharmacy_nearbyfind.dart';

const String apiBase = 'http://10.0.2.2:8000';

const String dataGoKrServiceKey = 'MU0rePMkjOV1Iy7RV9nc5lkVUVB0dNZ3OvPLs41lY2IUWkyW3TZyx32bpH9dPCUmWOR/fxyBx6od96LdOLqFFA==';
const String dataGoKrApiUrl = 'https://apis.data.go.kr/B552657/ErmctInsttInfoInqireService/getParmacyFullDown';

// 두 지점 간 거리를 미터 단위로 계산하는 함수 (Haversine 공식)
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  var p = 0.017453292519943295; // Math.PI / 180
  var c = cos; // cos 함수를 사용하기 위해 임포트 필요
  var a = 0.5 - c((lat2 - lat1) * p)/2 +
      c(lat1 * p) * c(lat2 * p) *
          (1 - c((lon2 - lon1) * p))/2;
  return 1000 * 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
}

class PharmacyFindPage extends StatefulWidget {
  const PharmacyFindPage({Key? key}) : super(key: key);

  @override
  _PharmacyFindPageState createState() => _PharmacyFindPageState();
}

class _PharmacyFindPageState extends State<PharmacyFindPage> {
  bool _isLoading = true;
  String _message = '주변 약국 정보를 가져오는 중...';

  @override
  void initState() {
    super.initState();
    _findNearbyPharmacies();
  }

  Future<void> _findNearbyPharmacies() async {
    setState(() {
      _isLoading = true;
      _message = '현재 위치 찾는 중...';
    });

    try {
      // 1. 위치 권한 요청 및 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _message = '위치 권한이 거부되었습니다.';
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_message)),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _message = '위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요.';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_message)),
        );
        return;
      }

      // 2. 현재 위치 가져오기
      setState(() {
        _message = '현재 위치 가져오는 중...';
      });
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('현재 위치: ${position.latitude}, ${position.longitude}');

      // 3. 현재 위치의 주소(시도, 시군구) 가져오기
      setState(() {
        _message = '주소 정보 가져오는 중...';
      });
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      String sido = '';
      String sigungu = '';
      if (placemarks.isNotEmpty) {
        // 첫 번째 결과 사용
        sido = placemarks[0].administrativeArea ?? '';
        sigungu = placemarks[0].subAdministrativeArea ?? '';
        print('현재 주소: $sido $sigungu');
        if (sido.endsWith('특별자치시') || sido.endsWith('광역시') || sido.endsWith('특별시')) {
          if (sigungu.isEmpty && placemarks[0].locality != null && placemarks[0].locality!.isNotEmpty) {
            sigungu = placemarks[0].locality!;
          }
        }

        // 공백 제거 (API 요구사항 고려)
        sido = sido.replaceAll(' ', '');
        sigungu = sigungu.replaceAll(' ', '');

        print('API 호출용 주소: $sido $sigungu');

      } else {
        setState(() {
          _message = '주소 정보를 가져오는데 실패했습니다.';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_message)),
        );
        return;
      }

      // 4. 약국 전체 목록 검색 (새 API 사용)
      setState(() {
        _message = '약국 전체 목록 검색 중...';
      });

      // URL 구성 (GET 방식, 서비스 키, 페이지 번호, 결과 수 사용)
      final url = Uri.parse('$dataGoKrApiUrl'
          '?serviceKey=${Uri.encodeComponent(dataGoKrServiceKey)}'
          '&pageNo=1' // 첫 페이지 요청
          '&numOfRows=5000' // 충분히 많은 결과를 가져오도록 조정 (API 제한 확인 필요)
      );

      print('API 요청 URL: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<MedicalFacility> allPharmacies = [];
        try {
          final document = XmlDocument.parse(utf8.decode(response.bodyBytes));
          final items = document.findAllElements('item');

          if (items.isNotEmpty) {
            allPharmacies = items.map((node) {
              final Map<String, dynamic> itemMap = {};
              for (final child in node.children) {
                if (child is XmlElement) {
                  itemMap[child.name.local] = child.text;
                }
              }
              // MedicalFacility.fromJson을 호출하기 전에 wgs84Lat, wgs84Lon이 숫자인지 확인
              if (itemMap['wgs84Lat'] != null && itemMap['wgs84Lon'] != null) {
                try {
                  double.parse(itemMap['wgs84Lat'].toString());
                  double.parse(itemMap['wgs84Lon'].toString());
                } catch (e) {
                  // 파싱 오류 발생 시 해당 항목 제외 (또는 기본값 처리)
                  print('경위도 파싱 오류 또는 null: ${itemMap['dutyName']}');
                  return null; // 유효하지 않은 항목은 null 반환
                }
              }
              return MedicalFacility.fromJson(itemMap);
            }).where((facility) => facility != null).toList().cast<MedicalFacility>(); // null 항목 필터링 및 타입 캐스팅
          }

        } catch (e) {
          print('XML 파싱 오류: $e');
          setState(() {
            _message = 'API 응답 파싱 오류: $e';
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_message)),
          );
          return;
        }

        // 4-1. 현재 위치 기준 500m 반경 약국 필터링
        List<MedicalFacility> nearbyPharmacies = allPharmacies.where((facility) {
          if (facility.wgs84Lat != null && facility.wgs84Lon != null) {
            try {
              final double lat = double.parse(facility.wgs84Lat!);
              final double lon = double.parse(facility.wgs84Lon!);
              final double distance = calculateDistance(position.latitude, position.longitude, lat, lon);
              // MedicalFacility 객체에 거리 정보 저장 (선택 사항)
              //facility.distance = distance; // MedicalFacility 모델에 distance 필드 추가 필요
              return distance <= 500; // 500m (500 미터) 이내의 약국만 포함
            } catch (e) {
              print('거리 계산 오류: ${facility.dutyName}, $e');
              return false; // 오류 발생 시 제외
            }
          }
          return false; // 경위도 정보가 없는 약국은 제외
        }).toList();

        // (선택 사항) 거리가 가까운 순으로 정렬
        nearbyPharmacies.sort((a, b) => (a.distance ?? double.infinity).compareTo(b.distance ?? double.infinity));

        // 5. 지도 화면으로 이동 (필터링된 약국 목록을 NearbyMedicalMapWidget에 전달)
        if (nearbyPharmacies.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NearbyMedicalMapWidget(
                currentPosition: position,
                facilities: nearbyPharmacies, // 필터링된 약국 목록 전달
                title: '내 주변 약국 찾기',
              ),
            ),
          );
        } else {
          setState(() {
            _message = '주변 500m 이내에 운영 중인 약국이 없습니다.';
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_message)),
          );
        }

      } else {
        String errorMessage = 'API 호출 실패: ${response.statusCode}';
        if (response.body.contains('SERVICE_KEY_IS_NOT_REGISTERED_ERROR')) {
          errorMessage = 'API 서비스 키 오류 또는 만료.';
        } else if (response.body.contains('NODATA_ERROR')) {
          errorMessage = '검색 결과가 없습니다.';
        }
        setState(() {
          _message = errorMessage;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_message)),
        );
        print('API 응답 오류: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      setState(() {
        _message = '오류 발생: $e';
        _isLoading = false;
      });
      print('오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 주변 약국 찾기'),
      ),
      body: Center(
        child: _isLoading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(_message),
          ],
        )
            : Text(_message),
      ),
    );
  }
}