import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('language_selection'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageTile(context, 'ko', 'korean'),
          _buildLanguageTile(context, 'en', 'english'),
          _buildLanguageTile(context, 'ja', 'japanese'),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, String code, String key) {
    return ListTile(
      title: Text(key.tr()),
      onTap: () {
        context.setLocale(Locale(code));
        Navigator.pop(context);
      },
      trailing: context.locale.languageCode == code
          ? const Icon(Icons.check, color: Colors.green)
          : null,
    );
  }
}
