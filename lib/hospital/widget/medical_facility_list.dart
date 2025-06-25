// 의료기관 검색 화면에서 병원 리스트 컴포넌트

import 'package:flutter/material.dart';
import '../../component/medical_facility.dart';
import 'medical_facility_card.dart';

class MedicalFacilityList extends StatelessWidget {
  final List<MedicalFacility> facilities;
  final bool isLoading;
  final bool isPaginating;
  final ScrollController scrollController;
  final Function(MedicalFacility) onTapCard;

  const MedicalFacilityList({
    required this.facilities,
    required this.isLoading,
    required this.isPaginating,
    required this.scrollController,
    required this.onTapCard,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading && facilities.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    if (facilities.isEmpty) {
      return Center(child: Text('검색 결과가 없습니다.'));
    }
    return ListView.builder(
      controller: scrollController,
      itemCount: facilities.length + (isPaginating ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == facilities.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final f = facilities[index];
        String? distanceText;
        if (f.distance != null && f.distance != double.infinity) {
          distanceText = _formatDistance(f.distance!);
        }
        return MedicalFacilityCard(
          facility: f,
          distanceText: distanceText,
          onTap: () => onTapCard(f),
        );
      },
    );
  }

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.round()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }
}