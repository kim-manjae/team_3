import 'package:flutter/material.dart';
import 'hospital/hospital_main.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:easy_localization/easy_localization.dart';

/// 애플리케이션의 진입점
///
/// 이 함수는 앱의 초기화 작업을 수행합니다:
/// 1. Flutter 엔진 초기화
/// 2. 다국어 지원 초기화
/// 3. 네이버 지도 API 초기화
/// 4. 앱 실행
void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();
  // 다국어 지원 초기화
  await EasyLocalization.ensureInitialized();

  // 네이버 지도 API 초기화
  await FlutterNaverMap().init(
      clientId: 'q884t9qoyu',
      onAuthFailed: (ex) => switch (ex) {
        NQuotaExceededException(:final message) =>
            print("사용량 초과 (message: $message)"),
        NUnauthorizedClientException() ||
        NClientUnspecifiedException() ||
        NAnotherAuthFailedException() =>
            print("인증 실패: $ex"),
      });

  // 앱 실행
  runApp(
    EasyLocalization(
      // 지원하는 언어 설정
      supportedLocales: const [
        Locale('ko'), // 한국어
        Locale('en'), // 영어
        Locale('ja'), // 일본어
      ],
      path: 'assets/langs', // 번역 파일 경로
      fallbackLocale: const Locale('ko'), // 기본 언어
      startLocale: const Locale('ko'), // 시작 언어
      useOnlyLangCode: true, // 언어 코드만 사용
      child: const MyApp(),
    ),
  );
}

/// 앱의 루트 위젯
///
/// 이 클래스는 앱의 기본 설정을 정의합니다:
/// - 앱 제목
/// - 테마 설정
/// - 다국어 지원 설정
/// - 초기 화면 설정
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '의료기관 검색',
      // 앱의 기본 테마 설정
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // 다국어 지원 설정
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // 앱의 초기 화면을 병원 메인 페이지로 설정
      home: HospitalMainPage(),
    );
  }
}