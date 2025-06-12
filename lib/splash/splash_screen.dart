// lib/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:project/component/medical_facility.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../service/social_login.dart';        // ← LoginWidget 정의된 곳
import '../service/location_service.dart';
import '../service/pharmacy_service.dart';
import '../state/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1) .env 로드
      await dotenv.load(fileName: ".env");

      // 2) SDK 초기화
      final naverId = dotenv.env['NAVER_MAP_CLIENT_ID']!;
      final kakaoKey = dotenv.env['KAKAO_SDK_APP_KEY']!;
      FlutterNaverMap().init(
        clientId: naverId,
        onAuthFailed: (e) => debugPrint('NaverMap Auth Failed: $e'),
      );
      KakaoSdk.init(nativeAppKey: kakaoKey);

      // 3) 위치 권한 & 현재 위치 획득
      final pos = await LocationService.getCurrentPosition();
      if (!mounted) return;
      context.read<AppState>().position = pos;

      // 4) 약국 데이터 미리 불러오기
      List<MedicalFacility> pharmacies;
      try {
        pharmacies = await PharmacyService.fetchNearbyPharmacies(pos);
      } catch (e) {
        // "주변 500m 이내 약국 없음" 예외라면 빈 리스트로 처리
        final noNearbyMsg = 'pharmacy.no_nearby'.tr();
        if (e.toString().contains(noNearbyMsg)) {
          pharmacies = <MedicalFacility>[];
        } else {
          rethrow;  // 그 외 에러는 다시 던져서 catch 블록으로
        }
      }
      if (!mounted) return;
      context.read<AppState>().pharmacies = pharmacies;

      // 5) 잠깐 대기
      await Future.delayed(const Duration(milliseconds: 300));

      // 6) 로그인 화면으로 이동 (social_login.dart의 LoginWidget)
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginWidget()),
      );
    } catch (e) {
      debugPrint('Splash init error: $e');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('error'.tr()),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginWidget()),
                );
              },
              child: Text('ok'.tr()),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('로딩 중 입니다.'),
          ],
        ),
      ),
    );
  }
}
