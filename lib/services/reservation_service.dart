import '../models/reservation.dart';

/// 예약 관리를 위한 서비스 클래스
///
/// 이 클래스는 예약 정보의 CRUD(Create, Read, Update, Delete) 작업을 담당합니다.
/// 현재는 메모리 내에서 예약을 관리하지만, 추후 Firebase Firestore와 연동하여
/// 영구적인 데이터 저장이 가능하도록 확장할 수 있습니다.
class ReservationService {
  /// 예약 정보를 저장하는 내부 리스트
  ///
  /// 현재는 메모리 내에서만 관리되며, 앱이 종료되면 데이터가 초기화됩니다.
  static final List<Reservation> _reservations = [];

  /// 현재 저장된 모든 예약 목록을 반환
  ///
  /// 외부에서 예약 목록을 수정할 수 없도록 불변 리스트로 반환합니다.
  static List<Reservation> get reservations => List.unmodifiable(_reservations);

  /// 새로운 예약을 추가하는 메서드
  ///
  /// [reservation] 추가할 예약 정보
  static void addReservation(Reservation reservation) {
    _reservations.add(reservation);
  }

  /// 기존 예약을 삭제하는 메서드
  ///
  /// [reservation] 삭제할 예약 정보
  static void removeReservation(Reservation reservation) {
    _reservations.remove(reservation);
  }

  /// 특정 사용자의 예약 목록을 조회하는 메서드
  ///
  /// [userId] 조회할 사용자의 ID
  /// Returns: 해당 사용자의 모든 예약 목록
  static List<Reservation> getReservationsByUserId(String userId) {
    return _reservations.where((r) => r.userId == userId).toList();
  }
}