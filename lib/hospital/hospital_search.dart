// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
// import '../component/medical_facility.dart';
// import '../map/medical_map.dart';
// import '../pharmacy/pharmacy_nearbyfind.dart';
// import '../pharmacy/pharmacy_find.dart';
// import 'dart:math';
// import '../component/medical_facility_detailpage.dart';
//
// const String apiBase = 'http://10.0.2.2:8000';
//
// class HospitalSearchPage extends StatefulWidget {
//   @override
//   _HospitalSearchPageState createState() => _HospitalSearchPageState();
// }
//
// class _HospitalSearchPageState extends State<HospitalSearchPage> with SingleTickerProviderStateMixin {
//   List<MedicalFacility> facilities = [];
//   bool isLoading = false; // 초기 로딩 상태
//   bool _isPaginating = false; // 다음 페이지 로딩 상태
//   String searchKeyword = '';
//   Position? currentPosition;
//
//   bool isNationwide = true;
//   String selectedRegion = '서울특별시';
//
//   int _currentPage = 1; // 현재 페이지 번호
//   final int _itemsPerPage = 20; // 한 페이지에 가져올 항목 수 (서버 기본값 20 사용 권장)
//   int _totalCount = 0; // 전체 결과 수
//
//   final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러
//
//   final List<String> regions = [
//     '서울특별시', '부산광역시', '대구광역시', '인천광역시', '광주광역시',
//     '대전광역시', '울산광역시', '세종특별자치시', '경기도', '강원도',
//     '충청북도', '충청남도', '전라북도', '전라남도', '경상북도',
//     '경상남도', '제주특별자치도',
//   ];
//
//   final TextEditingController _searchController = TextEditingController();
//
//   bool showNearbyOnly = false;
//   double nearbyRadius = 5000; // 기본값(미사용)
//
//   late TabController _tabController;
//   final List<String> subjects = [
//     '내 주변',
//     '내과',
//     '외과',
//     '소아과',
//     '정형외과',
//     '이비인후과',
//     '피부과',
//     '안과',
//     '신경과',
//     '신경외과',
//     '산부인과',
//     '비뇨기과',
//     '정신건강의학과',
//     '가정의학과',
//     '치과',
//     '한의원',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     // _getCurrentLocationAndFetch(); // 초기 로딩 (주변 병원) 호출 제거
//
//     // 스크롤 리스너 추가
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
//         // 스크롤이 맨 아래에 도달했을 때
//         _loadNextPage();
//       }
//     });
//
//     _tabController = TabController(length: subjects.length, vsync: this);
//     _tabController.addListener(() {
//       if (_tabController.indexIsChanging) return;
//       if (_tabController.index == 0) {
//         _showNearbyHospitals();
//       } else {
//         _searchBySubject(subjects[_tabController.index]);
//       }
//     });
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _showNearbyHospitals();
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose(); // 컨트롤러 해제
//     _searchController.dispose(); // 컨트롤러 해제
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   // 키워드 검색 시작 시 호출 (첫 페이지)
//   Future<void> _startNewSearch() async {
//     if (isLoading) return;
//
//     setState(() {
//       isLoading = true;
//       facilities.clear();
//       _currentPage = 1;
//       _totalCount = 0;
//     });
//
//     try {
//       await _fetchData(pageNo: _currentPage);
//     } catch (e) {
//       print("Error during new search: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
//       );
//       setState(() {
//         facilities = [];
//         _totalCount = 0;
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   // 위치 정보 가져오기 (주변 약국 찾기 시 필요)
//   Future<void> _getCurrentLocationAndFetch() async {
//     // 이미 로딩 중이면 중복 실행 방지
//     if (isLoading) return;
//
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       // 1. 위치 권한 요청 및 확인
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('위치 권한이 거부되었습니다')),
//           );
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요')),
//         );
//         return;
//       }
//
//       // 2. 현재 위치 가져오기
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         currentPosition = position;
//       });
//       print('현재 위치: ${position.latitude}, ${position.longitude}');
//
//       // 3. 주변 약국 검색 및 지도 페이지로 이동
//       await _findNearbyPharmacies(position);
//
//     } catch (e) {
//       // 위치 정보 가져오기 실패 시 처리
//       print('위치 정보를 가져오는데 실패했습니다: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('위치 정보를 가져오는데 실패했습니다: $e')),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   // 주변 약국 찾기 (위치 정보를 인자로 받도록 수정)
//   Future<void> _findNearbyPharmacies(Position position) async {
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       final response = await http.get(
//         Uri.parse('$apiBase/api/medical/nearby?'
//             'latitude=${position.latitude}'
//             '&longitude=${position.longitude}'
//             '&radius=1000' // 1km 반경
//             '&is_open=true' // 운영중인 곳만
//             '&type=pharmacy'), // 약국만 검색
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(utf8.decode(response.bodyBytes));
//         final List items = data['items'] ?? [];
//         final pharmacies = items.map((item) => MedicalFacility.fromJson(item)).toList();
//
//         // 4. 지도 화면으로 이동 (NearbyMedicalMapWidget 사용)
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => NearbyMedicalMapWidget(
//               currentPosition: position,
//               facilities: pharmacies, // 약국 목록이 비어있을 수도 있음
//               title: '주변 약국 찾아보기',
//             ),
//           ),
//         );
//
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('약국 검색 중 오류가 발생했습니다')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('약국 검색 중 오류가 발생했습니다: $e')),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   // 다음 페이지 로드
//   Future<void> _loadNextPage() async {
//     // 이미 로딩 중이거나, 더 이상 로드할 데이터가 없으면 중복 호출 방지
//     if (isLoading || _isPaginating || facilities.length >= _totalCount) {
//       // 스크롤 끝에 도달했지만 더 이상 로드할 페이지가 없을 경우 토스트 메시지 표시
//       // 여기서 토스트가 표시될 조건: 로딩 중이 아니고, 결과가 있으며, 로드된 수가 전체와 같거나 많고, 전체 수가 1페이지보다 많은 경우
//       if (!_isPaginating && facilities.isNotEmpty && facilities.length >= _totalCount && _totalCount > _itemsPerPage) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('마지막 결과입니다.'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//       return; // 로드할 데이터가 없으면 여기서 함수 종료
//     }
//
//     setState(() {
//       _isPaginating = true; // 다음 페이지 로딩 시작
//       _currentPage++; // 페이지 번호 증가
//     });
//
//     try {
//       // 키워드 검색 페이지만 처리
//       await _fetchData(pageNo: _currentPage);
//
//     } catch (e) {
//       print("Error during loading next page: $e");
//       // 에러 처리
//     } finally {
//       setState(() => _isPaginating = false); // 다음 페이지 로딩 완료
//       // 다음 페이지 로딩 후, 로드된 항목 수가 전체 결과 수와 같거나 많으면 토스트 메시지 표시
//       // 이 위치에서 다시 체크하는 이유는 _fetchData 내에서 상태가 업데이트되기 때문
//       if (facilities.isNotEmpty && facilities.length >= _totalCount && _totalCount > _itemsPerPage) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('마지막 결과입니다.'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     }
//   }
//
//   // 데이터 가져오는 공통 함수
//   Future<void> _fetchData({required int pageNo}) async {
//     String url;
//     String base = '$apiBase/api/medical/search?QN=${_searchController.text.trim()}&page_no=$pageNo&num_of_rows=$_itemsPerPage';
//     if (!isNationwide) {
//       base += '&Q0=$selectedRegion';
//     }
//     if (currentPosition != null) {
//       base += '&latitude=${currentPosition!.latitude}&longitude=${currentPosition!.longitude}';
//     }
//     url = base;
//
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(utf8.decode(response.bodyBytes));
//         final List items = data['items'] ?? [];
//         final int totalCount = data['total_count'] ?? 0;
//
//         setState(() {
//           if (pageNo == 1) {
//             facilities = items.map((e) => MedicalFacility.fromJson(e)).toList();
//           } else {
//             facilities.addAll(items.map((e) => MedicalFacility.fromJson(e)).toList());
//           }
//           _totalCount = totalCount; // 전체 결과 수 업데이트
//         });
//
//         if (facilities.isEmpty && pageNo == 1) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('검색 결과가 없습니다')),
//           );
//         }
//
//       } else {
//         print("Failed to fetch data: ${response.statusCode}");
//         if (pageNo == 1) {
//           setState(() { facilities = []; _totalCount = 0; });
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('데이터 가져오기 실패: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       print("Error during http request: $e");
//       if (pageNo == 1) {
//         setState(() { facilities = []; _totalCount = 0; });
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('데이터 가져오기 오류: $e')),
//       );
//     }
//   }
//
//   // 1. 내 주변 병원 찾기 버튼용 메서드 추가 (HospitalSearchPageState 내부)
//   Future<void> _findNearbyHospitals() async {
//     setState(() { isLoading = true; });
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('위치 권한이 거부되었습니다')),
//           );
//           return;
//         }
//       }
//       if (permission == LocationPermission.deniedForever) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요')),
//         );
//         return;
//       }
//       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//       setState(() { currentPosition = position; });
//       // 5km 반경 병원만 검색
//       final response = await http.get(Uri.parse('$apiBase/api/medical/nearby?latitude=${position.latitude}&longitude=${position.longitude}&radius=5000&type=hospital'));
//       if (response.statusCode == 200) {
//         final data = json.decode(utf8.decode(response.bodyBytes));
//         final List items = data['items'] ?? [];
//         final hospitals = items.map((item) => MedicalFacility.fromJson(item)).toList();
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SearchResultPage(
//               searchKeyword: '',
//               isNationwide: true,
//               selectedRegion: '',
//               initialFacilities: hospitals,
//               currentPosition: position,
//               showNearbyOnlyDefault: false,
//               nearbyRadiusMeter: 10000,
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('병원 검색 중 오류가 발생했습니다')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('위치 정보를 가져오는데 실패했습니다: $e')),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('의료기관 검색'),
//       ),
//       body: Center(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // 병원 찾기 박스
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => SearchResultPage(
//                       searchKeyword: '',
//                       isNationwide: false,
//                       selectedRegion: '',
//                       initialFacilities: [],
//                       currentPosition: currentPosition,
//                       showNearbyOnlyDefault: false,
//                       nearbyRadiusMeter: 10000,
//                     ),
//                   ),
//                 );
//               },
//               child: Container(
//                 width: 180,
//                 height: 200,
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.3),
//                       spreadRadius: 2,
//                       blurRadius: 5,
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.local_hospital,
//                       size: 50,
//                       color: Colors.blue,
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       '병원 찾기',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       '병원명 또는 주소로\n검색하세요',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.blue.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(width: 20),
//             // 내 주변 약국 찾기 박스
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PharmacyFindPage(),
//                   ),
//                 );
//               },
//               child: Container(
//                 width: 180,
//                 height: 200,
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.3),
//                       spreadRadius: 2,
//                       blurRadius: 5,
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.local_pharmacy,
//                       size: 50,
//                       color: Colors.green,
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       '내 주변 약국 찾기',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       '현재 위치 기준\n주변 약국을 찾아보세요',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.green.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _performSearch() {
//     final keyword = _searchController.text.trim();
//     if (keyword.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('검색어를 입력해주세요')),
//       );
//       return;
//     }
//     _startNewSearch();
//   }
//
//   // 거리 계산 함수 (Haversine 공식)
//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     const double earthRadius = 6371000; // 지구 반경 (미터)
//     final double dLat = _toRadians(lat2 - lat1);
//     final double dLon = _toRadians(lon2 - lon1);
//
//     final double a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
//             sin(dLon / 2) * sin(dLon / 2);
//
//     final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return earthRadius * c;
//   }
//
//   double _toRadians(double degree) {
//     return degree * pi / 180;
//   }
//
//   // 거리 문자열 포맷팅 함수
//   String formatDistance(double distance) {
//     if (distance < 1000) {
//       return '${distance.round()}m';
//     } else {
//       return '${(distance / 1000).toStringAsFixed(1)}km';
//     }
//   }
//
//   // 위도/경도 문자열을 double로 변환하는 함수
//   double? parseCoordinate(String? coord) {
//     if (coord == null || coord.isEmpty) return null;
//     try {
//       return double.parse(coord);
//     } catch (e) {
//       print('좌표 파싱 오류: $e');
//       return null;
//     }
//   }
//
//   // 현재 위치 가져오기
//   Future<void> _getCurrentLocationAndStartSearch() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('위치 권한이 거부되었습니다')),
//           );
//           _startNewSearch();
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요')),
//         );
//         _startNewSearch();
//         return;
//       }
//
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high
//       );
//       setState(() {
//         currentPosition = position;
//       });
//     } catch (e) {
//       print('위치 정보를 가져오는데 실패했습니다: $e');
//     }
//     _startNewSearch();
//   }
//
//   // 내 위치 기준 nearbyRadius 이내 병원만 거리순으로 보여주는 함수
//   Future<void> _showNearbyHospitals() async {
//     setState(() { isLoading = true; });
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('위치 권한이 거부되었습니다')),
//           );
//           setState(() { isLoading = false; });
//           return;
//         }
//       }
//       if (permission == LocationPermission.deniedForever) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요')),
//         );
//         setState(() { isLoading = false; });
//         return;
//       }
//       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//       setState(() { currentPosition = position; });
//       // 서버에서 10km 이내 병원만 받아오도록 API 호출
//       final response = await http.get(Uri.parse('$apiBase/api/medical/nearby?latitude=${position.latitude}&longitude=${position.longitude}&radius=${nearbyRadius.toInt()}&type=hospital'));
//       if (response.statusCode == 200) {
//         final data = json.decode(utf8.decode(response.bodyBytes));
//         final List items = data['items'] ?? [];
//         List<MedicalFacility> hospitals = items.map((item) => MedicalFacility.fromJson(item)).toList();
//         // 각 병원의 거리 계산 및 할당
//         for (var facility in hospitals) {
//           double? lat = parseCoordinate(facility.wgs84Lat);
//           double? lon = parseCoordinate(facility.wgs84Lon);
//           if (lat != null && lon != null) {
//             facility.distance = calculateDistance(
//               position.latitude,
//               position.longitude,
//               lat,
//               lon,
//             );
//           } else {
//             facility.distance = double.infinity;
//           }
//         }
//         // 거리순 정렬
//         hospitals.sort((a, b) {
//           double ad = a.distance ?? double.infinity;
//           double bd = b.distance ?? double.infinity;
//           return ad.compareTo(bd);
//         });
//         setState(() {
//           facilities = hospitals;
//           isLoading = false;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('병원 검색 중 오류가 발생했습니다')),
//         );
//         setState(() { isLoading = false; });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('위치 정보를 가져오는데 실패했습니다: $e')),
//       );
//       setState(() { isLoading = false; });
//     }
//   }
//
//   void _searchBySubject(String subject) async {
//     setState(() {
//       isLoading = true;
//       facilities.clear();
//       _currentPage = 1;
//       _totalCount = 0;
//     });
//     await _fetchDataBySubject(subject: subject, pageNo: 1);
//     setState(() {
//       isLoading = false;
//     });
//   }
//
//   Future<void> _fetchDataBySubject({required String subject, required int pageNo}) async {
//     String url = '$apiBase/api/medical/search?QN=$subject&page_no=$pageNo&num_of_rows=$_itemsPerPage';
//     if (currentPosition != null) {
//       url += '&latitude=${currentPosition!.latitude}&longitude=${currentPosition!.longitude}';
//     }
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(utf8.decode(response.bodyBytes));
//         final List items = data['items'] ?? [];
//         final int totalCount = data['total_count'] ?? 0;
//         List<MedicalFacility> newFacilities = items.map((e) => MedicalFacility.fromJson(e)).toList();
//         if (currentPosition != null) {
//           for (var facility in newFacilities) {
//             double? lat = parseCoordinate(facility.wgs84Lat);
//             double? lon = parseCoordinate(facility.wgs84Lon);
//             if (lat != null && lon != null) {
//               facility.distance = calculateDistance(
//                 currentPosition!.latitude,
//                 currentPosition!.longitude,
//                 lat,
//                 lon,
//               );
//             } else {
//               facility.distance = double.infinity;
//             }
//           }
//           newFacilities.sort((a, b) {
//             if (a.distance == null && b.distance == null) return 0;
//             if (a.distance == null) return 1;
//             if (b.distance == null) return -1;
//             if (a.distance == double.infinity && b.distance == double.infinity) return 0;
//             if (a.distance == double.infinity) return 1;
//             if (b.distance == double.infinity) return -1;
//             return a.distance!.compareTo(b.distance!);
//           });
//         }
//         setState(() {
//           facilities = newFacilities;
//           _totalCount = totalCount;
//         });
//       } else {
//         setState(() {
//           facilities = [];
//           _totalCount = 0;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         facilities = [];
//         _totalCount = 0;
//       });
//     }
//   }
// }
//
// // 검색 결과 페이지 추가
// class SearchResultPage extends StatefulWidget {
//   final String searchKeyword;
//   final bool isNationwide;
//   final String selectedRegion;
//   final List<MedicalFacility> initialFacilities;
//   final Position? currentPosition;
//   final bool showNearbyOnlyDefault;
//   final double nearbyRadiusMeter;
//
//   const SearchResultPage({
//     required this.searchKeyword,
//     required this.isNationwide,
//     required this.selectedRegion,
//     required this.initialFacilities,
//     required this.currentPosition,
//     required this.showNearbyOnlyDefault,
//     required this.nearbyRadiusMeter,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   _SearchResultPageState createState() => _SearchResultPageState();
// }
//
// class _SearchResultPageState extends State<SearchResultPage> with SingleTickerProviderStateMixin {
//   // 상태 변수들
//   List<MedicalFacility> facilities = [];
//   bool isLoading = false;
//   bool _isPaginating = false; // 다음 페이지 로딩 상태
//   int _currentPage = 1;
//   final int _itemsPerPage = 25;
//   int _totalCount = 0;
//   Position? currentPosition;
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//
//   // 내 주변 병원만 보기 토글 (항상 true)
//   final bool showNearbyOnly = true;
//   double nearbyRadius = 10000; // 10km
//
//   late TabController _tabController;
//   final List<String> subjects = [
//     '내 주변',
//     '내과',
//     '외과',
//     '소아과',
//     '정형외과',
//     '이비인후과',
//     '피부과',
//     '안과',
//     '신경과',
//     '신경외과',
//     '산부인과',
//     '비뇨기과',
//     '정신건강의학과',
//     '가정의학과',
//     '치과',
//     '한의원',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.text = widget.searchKeyword;
//     _scrollController.addListener(_scrollListener);
//     nearbyRadius = widget.nearbyRadiusMeter;
//     currentPosition = widget.currentPosition;
//     _tabController = TabController(length: subjects.length, vsync: this);
//     _tabController.addListener(() {
//       if (_tabController.indexIsChanging) return;
//       if (_tabController.index == 0) {
//         _showNearbyHospitals();
//       } else {
//         _searchBySubject(subjects[_tabController.index]);
//       }
//     });
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _showNearbyHospitals();
//     });
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   // 스크롤 리스너
//   void _scrollListener() {
//     if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
//       if (!isLoading && !_isPaginating && facilities.length < _totalCount) {
//         _loadNextPage();
//       }
//     }
//   }
//
//   // 다음 페이지 로드
//   Future<void> _loadNextPage() async {
//     if (isLoading || _isPaginating || facilities.length >= _totalCount) {
//       if (!_isPaginating && facilities.isNotEmpty && facilities.length >= _totalCount) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('마지막 결과입니다.'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//       return;
//     }
//
//     setState(() {
//       _isPaginating = true;
//       _currentPage++;
//     });
//
//     try {
//       await _fetchData(pageNo: _currentPage);
//     } catch (e) {
//       print("Error during loading next page: $e");
//     } finally {
//       setState(() {
//         _isPaginating = false;
//       });
//     }
//   }
//
//   // 검색어로 새로 검색
//   void _performSearch() {
//     final keyword = _searchController.text.trim();
//     if (keyword.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('검색어를 입력해주세요')),
//       );
//       return;
//     }
//     _startNewSearch();
//   }
//
//   Future<void> _startNewSearch() async {
//     if (isLoading) return;
//
//     setState(() {
//       isLoading = true;
//       facilities.clear();
//       _currentPage = 1;
//       _totalCount = 0;
//     });
//
//     try {
//       await _fetchData(pageNo: _currentPage);
//     } catch (e) {
//       print("Error during new search: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
//       );
//       setState(() {
//         facilities = [];
//         _totalCount = 0;
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _fetchData({required int pageNo}) async {
//     String url;
//     String base = '$apiBase/api/medical/search?QN=${_searchController.text.trim()}&page_no=$pageNo&num_of_rows=$_itemsPerPage';
//     if (!widget.isNationwide) {
//       base += '&Q0=${widget.selectedRegion}';
//     }
//     if (currentPosition != null) {
//       base += '&latitude=${currentPosition!.latitude}&longitude=${currentPosition!.longitude}';
//     }
//     url = base;
//
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(utf8.decode(response.bodyBytes));
//         final List items = data['items'] ?? [];
//         final int totalCount = data['total_count'] ?? 0;
//
//         List<MedicalFacility> newFacilities = items.map((e) => MedicalFacility.fromJson(e)).toList();
//
//         // 현재 위치가 있는 경우 거리 계산 및 정렬
//         if (widget.currentPosition != null) {
//           // 각 병원의 거리 계산
//           for (var facility in newFacilities) {
//             double? lat = parseCoordinate(facility.wgs84Lat);
//             double? lon = parseCoordinate(facility.wgs84Lon);
//
//             if (lat != null && lon != null) {
//               // 거리를 미터 단위로 계산
//               facility.distance = calculateDistance(
//                 widget.currentPosition!.latitude,
//                 widget.currentPosition!.longitude,
//                 lat,
//                 lon,
//               );
//             } else {
//               // 위치 정보가 없는 경우 무한대 거리로 설정
//               facility.distance = double.infinity;
//             }
//           }
//
//           // 거리 기준으로 정렬 (위치 정보가 없는 경우 맨 뒤로)
//           newFacilities.sort((a, b) {
//             // 두 병원 모두 거리 정보가 없는 경우
//             if (a.distance == null && b.distance == null) return 0;
//
//             // a의 거리 정보만 없는 경우
//             if (a.distance == null) return 1;
//
//             // b의 거리 정보만 없는 경우
//             if (b.distance == null) return -1;
//
//             // 두 병원 모두 무한대 거리인 경우
//             if (a.distance == double.infinity && b.distance == double.infinity) return 0;
//
//             // a만 무한대 거리인 경우
//             if (a.distance == double.infinity) return 1;
//
//             // b만 무한대 거리인 경우
//             if (b.distance == double.infinity) return -1;
//
//             // 거리 비교 (가까운 순서대로 정렬)
//             return a.distance!.compareTo(b.distance!);
//           });
//         }
//
//         setState(() {
//           if (pageNo == 1) {
//             facilities = newFacilities;
//           } else {
//             // 추가 페이지 로드 시에도 거리 기준 정렬 유지
//             facilities.addAll(newFacilities);
//             // 전체 목록을 다시 거리 기준으로 정렬
//             facilities.sort((a, b) {
//               if (a.distance == null && b.distance == null) return 0;
//               if (a.distance == null) return 1;
//               if (b.distance == null) return -1;
//               if (a.distance == double.infinity && b.distance == double.infinity) return 0;
//               if (a.distance == double.infinity) return 1;
//               if (b.distance == double.infinity) return -1;
//               return a.distance!.compareTo(b.distance!);
//             });
//           }
//           _totalCount = totalCount;
//         });
//
//         if (facilities.isEmpty && pageNo == 1) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('검색 결과가 없습니다')),
//           );
//         }
//
//       } else {
//         print("Failed to fetch data: ${response.statusCode}");
//         if (pageNo == 1) {
//           setState(() {
//             facilities = [];
//             _totalCount = 0;
//           });
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('데이터 가져오기 실패: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       print("Error during http request: $e");
//       if (pageNo == 1) {
//         setState(() {
//           facilities = [];
//           _totalCount = 0;
//         });
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('데이터 가져오기 오류: $e')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   // 거리 계산 함수 (Haversine 공식)
//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     const double earthRadius = 6371000; // 지구 반경 (미터)
//     final double dLat = _toRadians(lat2 - lat1);
//     final double dLon = _toRadians(lon2 - lon1);
//
//     final double a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
//             sin(dLon / 2) * sin(dLon / 2);
//
//     final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return earthRadius * c;
//   }
//
//   double _toRadians(double degree) {
//     return degree * pi / 180;
//   }
//
//   // 거리 문자열 포맷팅 함수
//   String formatDistance(double distance) {
//     if (distance < 1000) {
//       return '${distance.round()}m';
//     } else {
//       return '${(distance / 1000).toStringAsFixed(1)}km';
//     }
//   }
//
//   // 위도/경도 문자열을 double로 변환하는 함수
//   double? parseCoordinate(String? coord) {
//     if (coord == null || coord.isEmpty) return null;
//     try {
//       return double.parse(coord);
//     } catch (e) {
//       print('좌표 파싱 오류: $e');
//       return null;
//     }
//   }
//
//   // 현재 위치 가져오기
//   Future<void> _getCurrentLocationAndStartSearch() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('위치 권한이 거부되었습니다')),
//           );
//           _startNewSearch();
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요')),
//         );
//         _startNewSearch();
//         return;
//       }
//
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high
//       );
//       setState(() {
//         currentPosition = position;
//       });
//     } catch (e) {
//       print('위치 정보를 가져오는데 실패했습니다: $e');
//     }
//     _startNewSearch();
//   }
//
//   // 내 위치 기준 nearbyRadius 이내 병원만 거리순으로 보여주는 함수
//   Future<void> _showNearbyHospitals() async {
//     setState(() { isLoading = true; });
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('위치 권한이 거부되었습니다')),
//           );
//           setState(() { isLoading = false; });
//           return;
//         }
//       }
//       if (permission == LocationPermission.deniedForever) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요')),
//         );
//         setState(() { isLoading = false; });
//         return;
//       }
//       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//       setState(() { currentPosition = position; });
//       // 서버에서 10km 이내 병원만 받아오도록 API 호출
//       final response = await http.get(Uri.parse('$apiBase/api/medical/nearby?latitude=${position.latitude}&longitude=${position.longitude}&radius=${nearbyRadius.toInt()}&type=hospital'));
//       if (response.statusCode == 200) {
//         final data = json.decode(utf8.decode(response.bodyBytes));
//         final List items = data['items'] ?? [];
//         List<MedicalFacility> hospitals = items.map((item) => MedicalFacility.fromJson(item)).toList();
//         // 각 병원의 거리 계산 및 할당
//         for (var facility in hospitals) {
//           double? lat = parseCoordinate(facility.wgs84Lat);
//           double? lon = parseCoordinate(facility.wgs84Lon);
//           if (lat != null && lon != null) {
//             facility.distance = calculateDistance(
//               position.latitude,
//               position.longitude,
//               lat,
//               lon,
//             );
//           } else {
//             facility.distance = double.infinity;
//           }
//         }
//         // 거리순 정렬
//         hospitals.sort((a, b) {
//           double ad = a.distance ?? double.infinity;
//           double bd = b.distance ?? double.infinity;
//           return ad.compareTo(bd);
//         });
//         setState(() {
//           facilities = hospitals;
//           isLoading = false;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('병원 검색 중 오류가 발생했습니다')),
//         );
//         setState(() { isLoading = false; });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('위치 정보를 가져오는데 실패했습니다: $e')),
//       );
//       setState(() { isLoading = false; });
//     }
//   }
//
//   void _searchBySubject(String subject) async {
//     setState(() {
//       isLoading = true;
//       facilities.clear();
//       _currentPage = 1;
//       _totalCount = 0;
//     });
//     await _fetchDataBySubject(subject: subject, pageNo: 1);
//     setState(() {
//       isLoading = false;
//     });
//   }
//
//   Future<void> _fetchDataBySubject({required String subject, required int pageNo}) async {
//     String url = '$apiBase/api/medical/search?QN=$subject&page_no=$pageNo&num_of_rows=$_itemsPerPage';
//     if (currentPosition != null) {
//       url += '&latitude=${currentPosition!.latitude}&longitude=${currentPosition!.longitude}';
//     }
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(utf8.decode(response.bodyBytes));
//         final List items = data['items'] ?? [];
//         final int totalCount = data['total_count'] ?? 0;
//         List<MedicalFacility> newFacilities = items.map((e) => MedicalFacility.fromJson(e)).toList();
//         if (currentPosition != null) {
//           for (var facility in newFacilities) {
//             double? lat = parseCoordinate(facility.wgs84Lat);
//             double? lon = parseCoordinate(facility.wgs84Lon);
//             if (lat != null && lon != null) {
//               facility.distance = calculateDistance(
//                 currentPosition!.latitude,
//                 currentPosition!.longitude,
//                 lat,
//                 lon,
//               );
//             } else {
//               facility.distance = double.infinity;
//             }
//           }
//           newFacilities.sort((a, b) {
//             if (a.distance == null && b.distance == null) return 0;
//             if (a.distance == null) return 1;
//             if (b.distance == null) return -1;
//             if (a.distance == double.infinity && b.distance == double.infinity) return 0;
//             if (a.distance == double.infinity) return 1;
//             if (b.distance == double.infinity) return -1;
//             return a.distance!.compareTo(b.distance!);
//           });
//         }
//         setState(() {
//           facilities = newFacilities;
//           _totalCount = totalCount;
//         });
//       } else {
//         setState(() {
//           facilities = [];
//           _totalCount = 0;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         facilities = [];
//         _totalCount = 0;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('병원 검색'),
//       ),
//       body: Column(
//         children: [
//           // 1. 검색창 항상 상단
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: '병원명, 주소, 진료과목 등 검색',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                     onSubmitted: (_) => _performSearch(),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: _performSearch,
//                   color: Colors.black,
//                 ),
//               ],
//             ),
//           ),
//           // 2. 진료과목 탭 (검색창 아래)
//           Container(
//             height: 44,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: subjects.length,
//               itemBuilder: (context, idx) {
//                 final selected = _tabController.index == idx;
//                 return GestureDetector(
//                   onTap: () {
//                     _tabController.animateTo(idx);
//                     if (idx == 0) {
//                       _showNearbyHospitals();
//                     } else {
//                       _searchBySubject(subjects[idx]);
//                     }
//                   },
//                   child: Container(
//                     margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//                     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: selected ? Colors.lightGreen : Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: selected ? Colors.lightGreen : Colors.grey.shade300,
//                         width: 2,
//                       ),
//                     ),
//                     child: Center(
//                       child: Text(
//                         subjects[idx],
//                         style: TextStyle(
//                           color: selected ? Colors.white : Colors.black,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           // 3. 검색 결과 리스트
//           Expanded(
//             child: isLoading && facilities.isEmpty
//                 ? Center(child: CircularProgressIndicator())
//                 : facilities.isEmpty
//                 ? Center(child: Text('검색 결과가 없습니다.'))
//                 : ListView.builder(
//               controller: _scrollController,
//               itemCount: facilities.length + (_isPaginating ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index == facilities.length) {
//                   return Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: CircularProgressIndicator(),
//                     ),
//                   );
//                 }
//                 final f = facilities[index];
//                 String? distanceText;
//                 if (f.distance != null && f.distance != double.infinity) {
//                   distanceText = formatDistance(f.distance!);
//                 }
//                 return Card(
//                   margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//                   elevation: 1.0,
//                   child: ListTile(
//                     contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
//                     title: Text(
//                       f.getCleanDutyName() ?? '이름 없음',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(f.dutyAddr ?? '주소 정보 없음'),
//                         Text('전화: ${f.dutyTel1 ?? '정보 없음'}'),
//                         Row(
//                           children: [
//                             Text(
//                               f.todayOpenStatusFromServer ?? '운영 상태 정보 없음',
//                               style: TextStyle(
//                                 color: f.todayOpenStatusFromServer == '운영중'
//                                     ? Colors.green
//                                     : f.todayOpenStatusFromServer == '운영종료'
//                                     ? Colors.red
//                                     : Colors.grey,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Spacer(),
//                             if (distanceText != null)
//                               Text(
//                                 distanceText,
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.normal,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => MedicalFacilityDetailPage(facility: f),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }