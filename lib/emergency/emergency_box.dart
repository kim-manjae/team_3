import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class EmergencyBox extends StatelessWidget {
  final VoidCallback onTap;
  const EmergencyBox({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8
            , horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.local_hospital, color: Colors.red[700], size: 32),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'emergency.box'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}