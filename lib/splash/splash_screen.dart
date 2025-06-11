import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:project/service/social_login.dart';      // LoginWidget 정의된 파일

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp(); // 초기화 시작
  }

  Future<void> _initializeApp() async {
    // 1) .env 로드
    await dotenv.load(fileName: ".env");

    // 2) 키 가져오기
    final naverClientId = dotenv.env['NAVER_MAP_CLIENT_ID']!;
    final kakaoAppKey = dotenv.env['KAKAO_SDK_APP_KEY']!;

    // 3) 네이버 지도 SDK 초기화
    FlutterNaverMap().init(
      clientId: naverClientId,
      onAuthFailed: (ex) {
        // 인증 실패 로그
        print('NaverMap Auth Failed: $ex');
      },
    );

    // 4) 카카오 SDK 초기화
    KakaoSdk.init(nativeAppKey: kakaoAppKey);

    // 2) 위치 권한 및 현재 위치
    final position = await _getCurrentPosition();

    // 3) 공공데이터 API 호출 · 파싱 · 필터 · 정렬
    final pharmacies = await _fetchNearbyPharmacies(position);

    // (선택) 조금 대기하거나 추가 초기화 작업
    await Future.delayed(const Duration(milliseconds: 500));

    // 5) 초기화 끝나면 로그인 화면으로 이동
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginWidget()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // 원하는 로고나 애니메이션을 넣어도 됩니다
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('로딩 중...'),
          ],
        ),
      ),
    );
  }
}
