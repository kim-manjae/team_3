import 'package:flutter/material.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';

//로그인 플랫폼 구분용 enum
enum LoginPlatform {
  google,
  kakao,
  naver,
}

//로그인 위젯(상태 관리가 필요한 StatefulWidget)
class LoginWidget extends StatefulWidget{
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  bool isLoggedIn = false;          //현재 로그인 여부
  String? nickname;                 //로그인한 사용자의 닉네임 (카카오, 네이버용)
  String? email;                    //로그인한 사용자의 이메일 (구글용)
  LoginPlatform? _loginPlatform;    //현재 로그인된 플랫폼
  //구글 로그인 객체 생성(OAuth scopes 포함)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
  );
  GoogleSignInAccount? _user;       //로그인된 구글 사용자 정보

  //구글 로그인 함수
  Future<void> loginWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      setState(() {
        _user = account;          //사용자 정보
        isLoggedIn = true;        //로그인 상태 true
        email = account?.email;   //이메일 저장
        nickname = null;          //카카오 사용자 정보가 아님을 명시
        _loginPlatform = LoginPlatform.google;    //플랫폼 설정
      });
      print('Google 로그인 성공 : ${_user?.displayName}, ${_user?.email}');
    } catch (e) {
      print('Google sign-in error : $e');
    }
  }

  //카카오 로그인 함수
  Future<void> loginWithKakao() async {
    try {
      //카카오톡 설치 여부 확인
      bool installed = await isKakaoTalkInstalled();
      OAuthToken token = installed
          ? await UserApi.instance.loginWithKakaoTalk()       //앱으로 로그인
          : await UserApi.instance.loginWithKakaoAccount();   //계정으로 로그인
      print('카카오 로그인 성공 : ${token.accessToken}');

      final user = await UserApi.instance.me();   //사용자 정보 가져오기
      print('카카오 사용자 정보 : ${user.kakaoAccount?.profile?.nickname}');

      setState(() {
        isLoggedIn = true;
        nickname = user.kakaoAccount?.profile?.nickname;    //닉네임 저장
        email = null;   //구글 사용자가 아님을 명시
        _loginPlatform = LoginPlatform.kakao;   //플랫폼 설정
      });
    } catch (e, stack) {
      print('카카오 로그인 실패 : $e');
      print('스택트레이스 : $stack');
    }
  }

  //네이버 로그인 함수
  Future<void> loginWithNaver() async {
    try {
      //로그인 시도
      final result = await FlutterNaverLogin.logIn();

      //로그인 성공 여부 체크
      if (result.status == NaverLoginStatus.loggedIn) {
        print('네이버 로그인 성공');
        //사용자 정보 얻기
        final user = await FlutterNaverLogin.getCurrentAccount();
        print('네이버 사용자 정보 : ${user?.name}');

        setState(() {
          isLoggedIn = true;
          nickname = user?.name;    //닉네임 저장
          email = null;             //구글 사용자 아님
          _loginPlatform = LoginPlatform.naver;   //플랫폼 설정
        });
      } else {
        print('네이버 로그인 취소 또는 실패');
      }
    } catch (e) {
      print('네이버 로그인 오류 : $e');
    }
  }

  //로그아웃 함수(플랫폼별 분기)
  Future <void> logout() async {
    try {
      if (_loginPlatform == LoginPlatform.google) {
        await _googleSignIn.signOut();      //구글 로그아웃
        print('Google 로그아웃 성공');
      } else if (_loginPlatform == LoginPlatform.kakao) {
        await UserApi.instance.logout();    //카카오 로그아웃
        print('카카오 로그아웃 성공');
      } else if (_loginPlatform == LoginPlatform.naver) {
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
      _loginPlatform = null;
      _user = null;
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
            //로그인된 경우 사용자 정보와 로그아웃 표시
            Text('환영합니다, ${nickname ?? email}님',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
              ElevatedButton(
                onPressed: logout,
                  child: Text(
                    _loginPlatform == LoginPlatform.kakao
                      ? '카카오톡 로그아웃'
                      : _loginPlatform == LoginPlatform.naver
                        ? '네이버 로그아웃'
                        : '구글 로그아웃',
              ),
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