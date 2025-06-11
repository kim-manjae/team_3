import 'dart:convert';
import 'dart:math';                             // ← cos, sqrt, asin
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:easy_localization/easy_localization.dart';
import '../component/medical_facility.dart';
import 'package:geolocator/geolocator.dart';

const _apiUrl = 'https://apis.data.go.kr/B552657/ErmctInsttInfoInqireService/getParmacyFullDown';

class PharmacyService {
  static Future<List<MedicalFacility>> fetchNearbyPharmacies(Position position) async {
    final serviceKey = dotenv.env['DATA_GOKR_KEY'];
    if (serviceKey == null) {
      throw Exception('DATA_GOKR_KEY not found in .env');
    }

    final uri = Uri.parse(
      '$_apiUrl'
          '?serviceKey=${Uri.encodeComponent(serviceKey)}'
          '&pageNo=1&numOfRows=5000',
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('pharmacy.api_error'.tr());
    }

    final doc = XmlDocument.parse(utf8.decode(resp.bodyBytes));
    final items = doc.findAllElements('item');

    final all = <MedicalFacility>[];
    for (final node in items) {
      final map = <String, String>{};
      for (final child in node.children.whereType<XmlElement>()) {
        map[child.name.local] = child.text;
      }
      final fac = MedicalFacility.fromJson(map);
      if (fac.wgs84Lat != null && fac.wgs84Lon != null) {
        all.add(fac);
      }
    }

    // Haversine 공식
    double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
      final p = pi / 180;
      final a = 0.5 -
          cos((lat2 - lat1) * p) / 2 +
          cos(lat1 * p) * cos(lat2 * p) *
              (1 - cos((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a)) * 1000; // km→m
    }

    final nearby = <MedicalFacility>[];
    for (final f in all) {
      final lat = double.parse(f.wgs84Lat!);
      final lon = double.parse(f.wgs84Lon!);
      final dist = calculateDistance(position.latitude, position.longitude, lat, lon);
      if (dist <= 500) {
        f.distance = dist;
        nearby.add(f);
      }
    }

    if (nearby.isEmpty) {
      throw Exception('pharmacy.no_nearby'.tr());

    }

    nearby.sort((a, b) => (a.distance!).compareTo(b.distance!));
    return nearby;
  }
}
