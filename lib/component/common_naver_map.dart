import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class CommonNaverMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String markerLabel;
  final double zoom;
  final double height;

  const CommonNaverMap({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.markerLabel,
    this.zoom = 16,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(latitude, longitude),
            zoom: zoom,
          ),
        ),
        onMapReady: (controller) async {
          final marker = NMarker(
            id: 'facility_marker',
            position: NLatLng(latitude, longitude),
          );
          marker.setCaption(NOverlayCaption(
            text: markerLabel,
            textSize: 14,
            color: Colors.blue,
          ));
          controller.addOverlay(marker);
        },
      ),
    );
  }
}