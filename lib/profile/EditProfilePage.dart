import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('내 정보 수정')),
      body: Center(child: Text('여기에 프로필 수정 폼을 넣으세요')),
    );
  }
}