import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:project/service/social_login.dart';

void main() async {
  //Flutter 엔진과 의 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();
  //카카오 SDK 초기화
  KakaoSdk.init(nativeAppKey: 'af1dbe4ec46db5309c04c6f09355da61');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginWidget(),
    );
  }
}