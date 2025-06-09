/// 사용자 인증을 관리하는 서비스 클래스
///
/// 현재는 임시로 메모리 내에서 로그인 상태만 관리합니다.
/// 추후 Firebase Authentication 등과 연동하여 실제 인증 기능을 구현할 수 있습니다.
class AuthService {
  /// 현재 로그인 상태를 저장하는 내부 변수
  static bool _isLoggedIn = false;

  /// 현재 로그인 상태를 반환하는 getter
  ///
  /// Returns: 사용자의 로그인 상태 (true: 로그인됨, false: 로그인되지 않음)
  static bool get isLoggedIn => _isLoggedIn;

  /// 사용자 로그인 처리
  ///
  /// 현재는 단순히 로그인 상태만 변경합니다.
  /// 추후 실제 인증 로직이 구현되면 이 메서드에서 처리할 수 있습니다.
  static void login() {
    _isLoggedIn = true;
  }

  /// 사용자 로그아웃 처리
  ///
  /// 현재는 단순히 로그인 상태만 변경합니다.
  /// 추후 실제 인증 로직이 구현되면 이 메서드에서 처리할 수 있습니다.
  static void logout() {
    _isLoggedIn = false;
  }
} 