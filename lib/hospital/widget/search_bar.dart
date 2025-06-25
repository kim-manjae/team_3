// 의료기관 검색 화면에서 검색창 컴포넌트

import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const SearchBar({required this.controller, required this.onSearch, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '병원명, 주소, 진료과목 등 검색',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: onSearch,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}