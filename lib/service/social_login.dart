import 'dart:convert';
import 'package:flutter/material.dart';
//소셜 로그인 관련 패키지
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:http/http.dart' as http;
import 'database_service.dart';   //DB 연동을 위한 사용자 정의 클래스

//로그인 플랫폼 구분용 enum
enum LoginPlatform {
  google,
  kakao,
  naver,
}

//로그인 위젯(상태 관리가 필요하므로 StatefulWidget사용)
class LoginWidget extends StatefulWidget{
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  bool isLoggedIn = false;          //현재 로그인 여부
  String? nickname;                 //로그인한 사용자의 닉네임 (카카오, 네이버용)
  String? email;                    //로그인한 사용자의 이메일 (구글용)
  String? loginPlatform;            //현재 로그인된 플랫폼
  String? profileImage;             //프로필 이미지 URL (카카오 전용)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
  );
  GoogleSignInAccount? _user;       //로그인된 구글 사용자 정보
  //DB 저장을 위한 서비스 인스턴스
  final DatabaseService _db = DatabaseService();

  //초기 실핼 시 DB 연결
  @override
  void initState() {
    super.initState();
    _db.connect();
  }

  //위젯 종료 시 DB 연결 해제
  @override
  void dispose() {
    _db.disconnect();
    super.dispose();
  }

  //Google 로그인 함수
  Future<void> loginWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return;  //로그인 취소 시 종료

      setState(() {
        _user = account;                  //사용자 정보
        isLoggedIn = true;                //로그인 상태 true
        email = account.email;            //이메일 저장
        nickname = account.displayName;   //카카오 사용자 정보가 아님을 명시
        loginPlatform = 'google';         //플랫폼 설정
        profileImage = '';                //구글은 프로필 이미지 저장 안함
      });
      print('Google 로그인 성공 : $nickname, $email');

      //DB에 사용자 정보 저장
      await _db.saveUserInfo(
        nickname: nickname ?? '익명',
        email: email!,
        loginPlatform: 'google',
        profileImage: profileImage ?? '',  //Google 로그인의 경우 빈 문자열 전달
      );
    } catch (e) {
      print('Google sign-in error : $e');
    }
  }

  //카카오 로그인 함수
  Future<void> loginWithKakao() async {
    try {
      //카카오톡 설치 여부에 따라 로그인 방식 선택
      bool installed = await isKakaoTalkInstalled();
      OAuthToken token = installed
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();
      print('카카오 로그인 성공: ${token.accessToken}');

      //사용자 정보 가져오기
      final user = await UserApi.instance.me();
      String? kakaoEmail = user.kakaoAccount?.email;
      String? kakaoNickname = user.kakaoAccount?.profile?.nickname;
      String? kakaoProfileImage = user.kakaoAccount?.profile?.profileImageUrl;

      print('카카오 사용자 정보: $kakaoNickname, $kakaoEmail');

      //이메일 제공 동의 여부 확인
      if (kakaoEmail == null) {
        print('카카오 이메일이 null입니다');
        print('emailNeedsAgreement: ${user.kakaoAccount?.emailNeedsAgreement}');
        print('isEmailValid: ${user.kakaoAccount?.isEmailValid}');
        print('isEmailVerified: ${user.kakaoAccount?.isEmailVerified}');

        //사용자에게 안내
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('카카오 계정에 이메일이 없거나 제공에 동의하지 않았습니다. 이메일 제공 설정을 확인해주세요.'),
            ),
          );
        }
        return;
      }
      
      //DB에 사용자 정보 저장
      await _db.saveUserInfo(
        email: kakaoEmail ?? 'unknown',
        nickname: kakaoNickname ?? 'unknown',
        loginPlatform: 'kakao',
        profileImage: kakaoProfileImage ?? '',
      );

      print('카카오 사용자 정보 저장 완료');

      //로그인 상태 갱신
      setState(() {
        isLoggedIn = true;
        nickname = kakaoNickname;
        email = kakaoEmail;
        loginPlatform = 'kakao';
        profileImage = kakaoProfileImage;
      });
    } catch (e, stack) {
      print('카카오 로그인 실패: $e');
      print('스택트레이스: $stack');
    }
  }

  //네이버 로그인 함수
  Future<void> loginWithNaver() async {
    try {
      final result = await FlutterNaverLogin.logIn();

      if (result.status == NaverLoginStatus.loggedIn) {
        final user = await FlutterNaverLogin.getCurrentAccount();
        String? naverEmail = user?.email;
        String? naverNickname = user?.name;

        print('네이버 사용자 정보: $naverNickname, $naverEmail');

        if (naverEmail == null) {
          print('네이버 이메일 정보가 없어 DB 저장 불가');
          return;
        }

        await _db.saveUserInfo(
          email: naverEmail,
          nickname: naverNickname ?? '익명',
          loginPlatform: 'naver',
          profileImage: '',
        );

        print('네이버 사용자 정보 저장 완료');

        setState(() {
          isLoggedIn = true;
          nickname = naverNickname;
          email = naverEmail;
          loginPlatform = 'naver';
          profileImage = '';
        });
      } else {
        print('네이버 로그인 취소 또는 실패');
      }
    } catch (e) {
      print('네이버 로그인 오류: $e');
    }
  }

  //로그아웃 함수(플랫폼별 분기)
  Future <void> logout() async {
    try {
      if (loginPlatform == 'google') {
        await _googleSignIn.signOut();      //구글 로그아웃
        print('Google 로그아웃 성공');
      } else if (loginPlatform == 'kakao') {
        await UserApi.instance.logout();    //카카오 로그아웃
        print('카카오 로그아웃 성공');
      } else if (loginPlatform == 'naver') {
        await FlutterNaverLogin.logOut();   //네이버 로그아웃
        print('네이버 로그아웃 성공');
      }
    } catch (e) {
      print('로그아웃 실패 : $e');
    }

    //상태 초기화
    setState(() {
      isLoggedIn = false;
      nickname = null;
      email = null;
      loginPlatform = null;
      _user = null;
      profileImage = null;
    });
  }

  //화면 UI 빌드
  @override
  Widget build(BuildContext context) {
    return Column(
      //세로 중앙 정렬
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoggedIn) ...[
          if (profileImage != null && profileImage!.isNotEmpty)
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(profileImage!),
            ),
          const SizedBox(height: 10),
          Text('환영합니다, ${nickname ?? '익명'}님'),
          if (email != null) Text('이메일: $email'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: logout,
            child: const Text('로그아웃'),
          ),
        ] else ...[
          Column(
            children: [
              //로그인되지 않은 경우 로그인 버튼 표시
              GestureDetector(
                //카카오 로그인
                onTap: loginWithKakao,
                  child: Image.asset('assets/images/kakao_login_medium_narrow.png',
                    width: 150,
                      height: 60,
                        fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                //네이버 로그인
                onTap: loginWithNaver,
                  child: Image.asset('assets/images/btnG_완성형.png',
                    width: 150,
                      height: 45,
                        fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                //구글 로그인
                onTap: loginWithGoogle,
                  child: Image.asset('assets/images/android_light_sq_SU@4x.png',
                    width: 150,
                      height: 60,
                        fit: BoxFit.contain,
                ),
              )
            ],
          ),
        ],
      ],
    );
  }
}