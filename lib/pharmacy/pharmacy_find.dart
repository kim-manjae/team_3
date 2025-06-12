import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:xml/xml.dart';
import 'dart:math' show cos, sqrt, asin;
import '../component/medical_facility.dart';
import 'pharmacy_nearbyfind.dart';
import 'package:easy_localization/easy_localization.dart';

const String dataGoKrServiceKey = 'Q7Knj2bDIIEEcUa+IssDHW01vO1JbDDmNzyarPtSuPBFJ0OPxjvLgwIi+aWtIKZt/4IHjIK6cBiFvXyBXD67dw==';
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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _initializeData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('find_pharmacy'.tr()),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'pharmacy.searching'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('find_pharmacy'.tr()),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(snapshot.error.toString()),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        return NearbyMedicalMapWidget(
          currentPosition: data['position'],
          facilities: data['pharmacies'],
          title: 'pharmacy.nearby',
        );
      },
    );
  }

  Future<Map<String, dynamic>> _initializeData() async {
    try {
      // 1. 위치 권한 확인 > 오래걸림
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('location_permission_denied'.tr());
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('location_permission_denied_forever'.tr());
      }

      // 2. 현재 위치 가져오기 > 오래걸림.
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. 약국 데이터 가져오기 > 네트워크 요청, 대량 응답 파싱 > 오래 걸림
      final url = Uri.parse('$dataGoKrApiUrl'
          '?serviceKey=${Uri.encodeComponent(dataGoKrServiceKey)}'
          '&pageNo=1'
          '&numOfRows=5000'
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('pharmacy.api_error'.tr());
      }

      List<MedicalFacility> allPharmacies = [];
      try {
        // # xml 파싱 > 대량 노드 처리로 오래 걸림
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
            if (itemMap['wgs84Lat'] != null && itemMap['wgs84Lon'] != null) {
              try {
                double.parse(itemMap['wgs84Lat'].toString());
                double.parse(itemMap['wgs84Lon'].toString());
              } catch (e) {
                return null;
              }
            }
            return MedicalFacility.fromJson(itemMap);
          }).where((facility) => facility != null).toList().cast<MedicalFacility>();
        }
      } catch (e) {
        throw Exception('pharmacy.parse_error'.tr());
      }

      // 4. 500m 이내 약국 필터링 > 반복문 내부에 거리계산
      List<MedicalFacility> nearbyPharmacies = allPharmacies.where((facility) {
        if (facility.wgs84Lat != null && facility.wgs84Lon != null) {
          try {
            final double lat = double.parse(facility.wgs84Lat!);
            final double lon = double.parse(facility.wgs84Lon!);
            final double distance = calculateDistance(
              position.latitude,
              position.longitude,
              lat,
              lon,
            );
            facility.distance = distance;
            return distance <= 500;
          } catch (e) {
            return false;
          }
        }
        return false;
      }).toList();

      if (nearbyPharmacies.isEmpty) {
        throw Exception('pharmacy.no_nearby'.tr());
      }

      // 5. 거리순 정렬
      nearbyPharmacies.sort((a, b) =>
          (a.distance ?? double.infinity).compareTo(b.distance ?? double.infinity));

      return {
        'position': position,
        'pharmacies': nearbyPharmacies,
      };
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}