import 'package:flutter/material.dart';

//소셜 로그인 관련 패키지
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:project/widgets/nav_main_page.dart';
import 'database_service.dart'; //DB 연동을 위한 사용자 정의 클래스
import 'email_auth_widget.dart';

//로그인 플랫폼 구분용 enum
enum LoginPlatform { google, kakao, naver, local, }
//로그인 위젯(상태 관리가 필요하므로 StatefulWidget사용)
class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  bool isLoggedIn = false; //현재 로그인 여부
  bool _showLocalLogin = false;
  String? nickname; //로그인한 사용자의 닉네임 (카카오, 네이버용)
  String? email; //로그인한 사용자의 이메일 (구글용)
  String? loginPlatform; //현재 로그인된 플랫폼
  String? profileImage; //프로필 이미지 URL (카카오 전용)
  GoogleSignInAccount? _user; //로그인된 구글 사용자 정보
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
  );

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

  Future <void> _updateLoginState({
    required bool loggedIn,
    String? platform,
    String? nick,
    String? mail,
    String? image
  }) async {
    setState(() {
      isLoggedIn = loggedIn;
      loginPlatform = platform;
      nickname = nick;
      email = mail;
      profileImage = image;
      _showLocalLogin = false;
    });
  }

  //로컬 로그인 성공 처리
  Future<void> loginWithLocal(String email, String nickname,
      String password) async {
    print('로컬 계정 로그인 성공');
    await _db.saveUserInfo(
      email: email,
      nickname: nickname,
      loginPlatform: 'local',
      profileImage: '',
      password: password,
    );
    await _updateLoginState(
        loggedIn: true,
        platform: 'local',
        nick: nickname,
        mail: email,
        image: null);
  }

  //Google 로그인 함수
  Future<void> loginWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return; //로그인 취소 시 종료

      await _updateLoginState(
        loggedIn: true,
        platform: 'google',
        nick: account.displayName,
        mail: account.email,
        image: '',
      );

      print('Google 계정 로그인 성공');
      print('Google 계정 사용자 정보');
      print('이름 : $nickname');
      print('이메일 : $email');

      //DB에 사용자 정보 저장
      await _db.saveUserInfo(
        nickname: account.displayName ?? '익명',
        email: account.email,
        loginPlatform: 'google',
        profileImage: profileImage ?? '', //Google 로그인의 경우 빈 문자열 전달
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

      //사용자 정보 가져오기
      final user = await UserApi.instance.me();
      String? kakaoEmail = user.kakaoAccount?.email;
      String? kakaoNickname = user.kakaoAccount?.profile?.nickname;
      String? kakaoProfileImage = user.kakaoAccount?.profile?.profileImageUrl;

      print('카카오 계정 로그인 성공 : ${token.accessToken}');
      print('카카오 계정 사용자 정보');
      print('이름 : $kakaoNickname');
      print('이메일 : $kakaoEmail');

      //이메일 제공 동의 여부 확인
      if (kakaoEmail == null) {
        //사용자에게 안내
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '카카오 계정에 이메일이 없거나 제공에 동의하지 않았습니다. 이메일 제공 설정을 확인해주세요.'),
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

      await _updateLoginState(
        loggedIn: true,
        platform: 'kakao',
        nick: kakaoNickname,
        mail: kakaoEmail,
        image: kakaoProfileImage,
      );
    } catch (e, stack) {
      print('카카오 계정 로그인 실패: $e');
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

        print('네이버 계정 로그인 성공');
        print('네이버 계정 사용자 정보');
        print('이름 : $naverNickname');
        print('이메일 : $naverEmail');

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

        await _updateLoginState(
            loggedIn: true,
            platform: 'naver',
            nick: naverNickname,
            mail: naverEmail,
            image: '');
      } else {
        print('네이버 계정 로그인 취소 또는 실패');
      }
    } catch (e) {
      print('네이버 계정 로그인 오류: $e');
    }
  }

  //로그아웃 함수(플랫폼별 분기)
  Future <void> logout() async {
    try {
      if (loginPlatform == 'google') {
        await _googleSignIn.signOut(); //구글 로그아웃
        print('Google 계정 로그아웃 성공');
      } else if (loginPlatform == 'kakao') {
        await UserApi.instance.logout(); //카카오 로그아웃
        print('카카오 계정 로그아웃 성공');
      } else if (loginPlatform == 'naver') {
        await FlutterNaverLogin.logOutAndDeleteToken(); //네이버 로그아웃
        print('네이버 계정 로그아웃 성공');
      } else if (loginPlatform == 'local') {
        print('로컬 계정 로그아웃 성공');
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

  //로컬 로그인 버튼 클릭 시 호출되는 함수
  void _showEmailAuthDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.9,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Scaffold(
                body: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '이메일 로그인',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0),
                            child: EmailAuthWidget(
                              onLoginSuccess: loginWithLocal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  //화면 UI 빌드
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery
                .of(context)
                .size
                .height,
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoggedIn) ...[
                  if (profileImage != null && profileImage!.isNotEmpty)
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(profileImage!),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    '환영합니다, ${nickname ?? '익명'}님',
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (email != null)
                    Text(
                      '이메일: $email',
                      style: const TextStyle(color: Colors.white),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: logout,
                    child: const Text('로그아웃'),
                  ),
                ] else
                  ...[
                    const SizedBox(height: 40),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showLocalLogin = !_showLocalLogin;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(150, 45),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        _showLocalLogin ? '로컬 로그인 폼 숨기기' : '로컬 로그인',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (_showLocalLogin)
                      Container(
                        height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.7,
                        padding: const EdgeInsets.all(16.0),
                        child: EmailAuthWidget(
                          onLoginSuccess: loginWithLocal,
                        ),
                      ),
                  ],
                const SizedBox(height: 5),
                // 소셜 로그인 버튼들
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: loginWithKakao,
                      child: Image.asset(
                        'assets/images/kakao_login.png',
                        width: 150,
                        height: 45,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: loginWithNaver,
                      child: Image.asset(
                        'assets/images/naver_login.png',
                        width: 150,
                        height: 45,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: loginWithGoogle,
                      child: Image.asset(
                        'assets/images/google_login.png',
                        width: 150,
                        height: 45,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              nav_MainPage()),
                        );
                      },
                      child: Container(
                          width: 150,
                          height: 45,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('로그인 하지않고 넘어가기',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}