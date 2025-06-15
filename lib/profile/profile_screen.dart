import 'package:flutter/material.dart';
import 'package:project/widgets/language_dialog.dart';
import 'package:easy_localization/easy_localization.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageDialog(),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title:  Text('내 정보',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () => _showLanguageDialog(context),
            tooltip: 'language_selection'.tr(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '사용자',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              _buildProfileSection(
                title: '개인정보',
                items: [
                  ProfileMenuItem(
                    icon: Icons.person_outline,
                    title: '내 정보 수정',
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.security,
                    title: '개인정보 보호',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildProfileSection(
                title: '알림 설정',
                items: [
                  ProfileMenuItem(
                    icon: Icons.notifications_none,
                    title: '알림 설정',
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.language,
                    title: '언어 설정',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildProfileSection(
                title: '기타',
                items: [
                  ProfileMenuItem(
                    icon: Icons.help_outline,
                    title: '도움말',
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.info_outline,
                    title: '앱 정보',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<ProfileMenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.black54,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
} 