/// 예약 정보를 담는 모델 클래스
/// 
/// 이 클래스는 병원 예약 시스템에서 사용되는 예약 정보를 관리합니다.
/// 각 예약은 병원 이름, 주소, 예약 날짜, 예약 시간, 사용자 ID를 포함합니다.
class Reservation {
  /// 병원의 이름
  final String hospitalName;

  /// 병원의 주소
  final String hospitalAddress;

  /// 예약 날짜 (DateTime 형식)
  final DateTime reservationDate;

  /// 예약 시간 (문자열 형식, 예: "14:30")
  final String reservationTime;

  /// 예약한 사용자의 고유 ID
  final String userId;

  /// Reservation 클래스의 생성자
  /// 
  /// [hospitalName] 병원 이름
  /// [hospitalAddress] 병원 주소
  /// [reservationDate] 예약 날짜
  /// [reservationTime] 예약 시간
  /// [userId] 사용자 ID
  Reservation({
    required this.hospitalName,
    required this.hospitalAddress,
    required this.reservationDate,
    required this.reservationTime,
    required this.userId,
  });

  /// 예약 정보를 JSON 형식으로 변환하는 메서드
  /// 
  /// Firebase Firestore에 데이터를 저장할 때 사용됩니다.
  /// 날짜는 ISO 8601 형식의 문자열로 변환됩니다.
  Map<String, dynamic> toJson() {
    return {
      'hospitalName': hospitalName,
      'hospitalAddress': hospitalAddress,
      'reservationDate': reservationDate.toIso8601String(),
      'reservationTime': reservationTime,
      'userId': userId,
    };
  }

  /// JSON 데이터로부터 Reservation 객체를 생성하는 팩토리 메서드
  /// 
  /// Firebase Firestore에서 데이터를 읽어올 때 사용됩니다.
  /// ISO 8601 형식의 날짜 문자열을 DateTime 객체로 변환합니다.
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      hospitalName: json['hospitalName'],
      hospitalAddress: json['hospitalAddress'],
      reservationDate: DateTime.parse(json['reservationDate']),
      reservationTime: json['reservationTime'],
      userId: json['userId'],
    );
  }
} 