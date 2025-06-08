// 의료기관 검색 화면에서 진료과목 탭바 컴포넌트

import 'package:flutter/material.dart';

class SubjectTabBar extends StatelessWidget {
  final List<String> subjects;
  final int selectedIndex;
  final Function(int) onTap;

  const SubjectTabBar({
    required this.subjects,
    required this.selectedIndex,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        itemBuilder: (context, idx) {
          final selected = selectedIndex == idx;
          return GestureDetector(
            onTap: () => onTap(idx),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? Colors.lightGreen : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? Colors.lightGreen : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  subjects[idx],
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}