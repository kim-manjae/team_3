import 'package:flutter/material.dart';

class SignupWidget extends StatefulWidget {
  /// 가입 성공 시 호출 (email, nickname, password)
  final void Function(String email, String nickname, String password) onSignup;
  const SignupWidget({Key? key, required this.onSignup}) : super(key: key);

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nickCtrl  = TextEditingController();
  final _pwCtrl    = TextEditingController();
  final _pw2Ctrl   = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nickCtrl.dispose();
    _pwCtrl.dispose();
    _pw2Ctrl.dispose();
    super.dispose();
  }

  void _trySignup() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSignup(
        _emailCtrl.text.trim(),
        _nickCtrl.text.trim(),
        _pwCtrl.text,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('회원가입',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),

                // 이메일
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? '이메일을 입력하세요' : null,
                ),
                const SizedBox(height: 16),

                // 닉네임
                TextFormField(
                  controller: _nickCtrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: '닉네임',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? '닉네임을 입력하세요' : null,
                ),
                const SizedBox(height: 16),

                // 비밀번호
                TextFormField(
                  controller: _pwCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    hintText: '비밀번호',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) return '비밀번호는 6자 이상';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 비밀번호 확인
                TextFormField(
                  controller: _pw2Ctrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: '비밀번호 확인',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) {
                    if (v != _pwCtrl.text) return '비밀번호가 일치하지 않습니다';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _trySignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4BB8EA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('가입하기',
                      style: TextStyle(fontSize: 18, color: Colors.white)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
