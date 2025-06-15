import 'package:postgres/postgres.dart';

class DatabaseService {
  //싱글톤 패턴 구현을 위한 인스턴스 변수
  static final DatabaseService _instance = DatabaseService._internal();
  //PostgreSQL 연결 객체
  late final PostgreSQLConnection _connection;
  //연결 상태 플래그
  bool _isConnected = false;

  //팩토리 생성자 : 항상 같은 인스턴스 반환
  factory DatabaseService() {
    return _instance;
  }

  //내부 생성자 (싱글톤용)
  DatabaseService._internal();

  //DB 연결 함수
  Future<void> connect() async {
    //이미 연결되어 있지 않은 경우에만 연결 시도
    if (!_isConnected) {
      try {
        _connection = PostgreSQLConnection(
          //DB 호스트 주소
          'database-1.ct8wqsmwwlb2.ap-northeast-2.rds.amazonaws.com',
          5432,                     //포트번호
          'postgres',               //DB 이름
          username: 'postgres',     //DB 접속 아이디
          password: 'admin1234',    //DB 접속 비밀번호
          useSSL: true,             //SSL 사용 여부
        );

        await _connection.open();   //DB 연결 오픈
        _isConnected = true;        //연결 상태 플래그 갱신
        print('데이터베이스 연결 성공');
      } catch (e) {
        print('데이터베이스 연결 실패: $e');
        rethrow;                    //에러를 상위 호출자에게 전달
      }
    }
  }

  //DB 연결 종료 함수
  Future<void> disconnect() async {
    if (_isConnected) {
      await _connection.close();    //DB 연결 종료
      _isConnected = false;         //연결 상태 플래그 갱신
      print('데이터베이스 연결 종료');
    }
  }

  //사용자 정보를 DB에 저장하는 함수(없으면 생성, 있으면 업데이트)
  Future<void> saveUserInfo({
    required String email,
    required String nickname,
    required String loginPlatform,
    required String profileImage,
  }) async {
    try {
      if (!_isConnected) {
        await connect();    //연결이 안 되어 있으면 연결부터 시도
      }

      //users 테이블이 없으면 생성
      //email과 platform 조합은 유니크해야함
      await _connection.execute('''
        CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        nickname VARCHAR(255) NOT NULL,
        platform VARCHAR(50) NOT NULL,
        profile_image TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(email, platform)
        )
      ''');

      //사용자 정보를 삽입하거나, 이미 있으면 닉네임과 프로필 이미지만 업데이트
      await _connection.execute('''
        INSERT INTO users (email, nickname, platform, profile_image)
        VALUES (@email, @nickname, @platform, @profile_image)
        ON CONFLICT (email, platform) 
        DO UPDATE SET 
          nickname = EXCLUDED.nickname,
          profile_image = EXCLUDED.profile_image
      ''', substitutionValues: {
        'email': email,
        'nickname': nickname,
        'platform': loginPlatform,
        'profile_image': profileImage,
      });

      print('사용자 정보 저장 성공');
    } catch (e) {
      print('사용자 정보 저장 실패: $e');
      rethrow;      //에러 상위 호출자에게 전달
    }
  }

  //이메일과 플랫폼으로 사용자 정보를 조회하는 함수
  Future<Map<String, dynamic>?> getUserInfo({
    required String email,
    required String loginPlatform,
  }) async {
    try {
      if (!_isConnected) {
        await connect();      //연결이 안 되어 있으면 연결 시도
      }

      //users 테이블에서 해당 이메일과 플랫폼에 맞는 사용자 정보 조회
      final results = await _connection.query(
        'SELECT * FROM users WHERE email = @email AND platform = @platform',
        substitutionValues: {'email': email, 'platform': loginPlatform},
      );

      //결과가 있으면 Map 형태로 반환
      if (results.isNotEmpty) {
        return {
          'email': results[0][1],           //이메일
          'nickname': results[0][2],        //닉네임
          'loginPlatform': results[0][3],   //로그인 플랫폼
          'profileImage': results[0][4],    //프로필 이미지 URL
        };
      }
      //결과가 없으면 null 반환
      return null;
    } catch (e) {
      print('사용자 정보 조회 실패: $e');
      rethrow;      //에러 상위 호출자에게 전달
    }
  }
}
