import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../component/medical_facility.dart';

class AppState extends ChangeNotifier {
  Position? _position;
  List<MedicalFacility>? _pharmacies;

  Position? get position => _position;
  List<MedicalFacility>? get pharmacies => _pharmacies;

  // getter 타입이 nullable 이므로 setter 파라미터도 nullable 로 맞춰줍니다.
  set position(Position? p) {
    _position = p;
    notifyListeners();
  }

  set pharmacies(List<MedicalFacility>? list) {
    _pharmacies = list;
    notifyListeners();
  }
}