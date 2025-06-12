// 검색/탭/리스트 화면만 담당
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../component/medical_facility.dart';
import '../component/medical_facility_detailpage.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'widget/medical_facility_card.dart';

const String apiBase = 'http://10.0.2.2:8000';

class HospitalSearchResultPage extends StatefulWidget {
  final Position? currentPosition;
  const HospitalSearchResultPage({Key? key, this.currentPosition}) : super(key: key);

  @override
  _HospitalSearchResultPageState createState() => _HospitalSearchResultPageState();
}

class _HospitalSearchResultPageState extends State<HospitalSearchResultPage> with SingleTickerProviderStateMixin {
  List<MedicalFacility> facilities = [];
  bool isLoading = false;
  bool _isPaginating = false;
  int _currentPage = 1;
  final int _itemsPerPage = 25;
  int _totalCount = 0;
  Position? currentPosition;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  late List<String> subjects;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _searchController.text = '';
    _scrollController.addListener(_scrollListener);
    currentPosition = widget.currentPosition;
    _initializeSubjects();
    _tabController = TabController(length: subjects.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_tabController.index == 0) {
        _showNearbyHospitals();
      } else {
        _searchBySubject(subjects[_tabController.index]);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNearbyHospitals();
    });
  }

  void _initializeSubjects() {
    final List<String> subjectKeys = [
      'subject_nearby',
      'subject_internal',
      'subject_surgery',
      'subject_pediatrics',
      'subject_orthopedics',
      'subject_ent',
      'subject_dermatology',
      'subject_ophthalmology',
      'subject_neurology',
      'subject_neurosurgery',
      'subject_obgyn',
      'subject_urology',
      'subject_psychiatry',
      'subject_family',
      'subject_dentistry',
      'subject_oriental',
    ];

    subjects = subjectKeys.map((key) => key.tr()).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeSubjects();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!isLoading && !_isPaginating && facilities.length < _totalCount) {
        _loadNextPage();
      }
    }
  }

  void _performSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('input_keyword'.tr())),
      );
      return;
    }
    _startNewSearch();
  }

  Future<void> _startNewSearch() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
      facilities.clear();
      _currentPage = 1;
      _totalCount = 0;
    });
    try {
      await _fetchData(pageNo: _currentPage);
    } catch (e) {
      setState(() {
        facilities = [];
        _totalCount = 0;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchData({required int pageNo}) async {
    if (!mounted) return;
    String url;
    String base = '$apiBase/api/medical/search?QN=${_searchController.text.trim()}&page_no=$pageNo&num_of_rows=$_itemsPerPage';
    if (currentPosition != null) {
      base += '&latitude=${currentPosition!.latitude}&longitude=${currentPosition!.longitude}';
    }
    url = base;
    try {
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List items = data['items'] ?? [];
        final int totalCount = data['total_count'] ?? 0;
        List<MedicalFacility> newFacilities = items.map((e) => MedicalFacility.fromJson(e)).toList();
        if (currentPosition != null) {
          for (var facility in newFacilities) {
            double? lat = parseCoordinate(facility.wgs84Lat);
            double? lon = parseCoordinate(facility.wgs84Lon);
            if (lat != null && lon != null) {
              facility.distance = calculateDistance(
                currentPosition!.latitude,
                currentPosition!.longitude,
                lat,
                lon,
              );
            } else {
              facility.distance = double.infinity;
            }
          }
          newFacilities.sort((a, b) {
            if (a.distance == null && b.distance == null) return 0;
            if (a.distance == null) return 1;
            if (b.distance == null) return -1;
            if (a.distance == double.infinity && b.distance == double.infinity) return 0;
            if (a.distance == double.infinity) return 1;
            if (b.distance == double.infinity) return -1;
            return a.distance!.compareTo(b.distance!);
          });
        }
        if (mounted) {
          setState(() {
            facilities = newFacilities;
            _totalCount = totalCount;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            facilities = [];
            _totalCount = 0;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          facilities = [];
          _totalCount = 0;
        });
      }
    }
  }

  void _searchBySubject(String subject) async {
    setState(() {
      isLoading = true;
      facilities.clear();
      _currentPage = 1;
      _totalCount = 0;
    });

    // 원래 번역 키로 검색
    final List<String> subjectKeys = [
      'subject_nearby',
      'subject_internal',
      'subject_surgery',
      'subject_pediatrics',
      'subject_orthopedics',
      'subject_ent',
      'subject_dermatology',
      'subject_ophthalmology',
      'subject_neurology',
      'subject_neurosurgery',
      'subject_obgyn',
      'subject_urology',
      'subject_psychiatry',
      'subject_family',
      'subject_dentistry',
      'subject_oriental',
    ];

    String originalKey = '';
    for (int i = 0; i < subjects.length; i++) {
      if (subjects[i] == subject) {
        originalKey = subjectKeys[i];
        break;
      }
    }

    await _fetchDataBySubject(subject: originalKey, pageNo: 1);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchDataBySubject({required String subject, required int pageNo}) async {
    String url = '$apiBase/api/medical/search?QN=$subject&page_no=$pageNo&num_of_rows=$_itemsPerPage';
    if (currentPosition != null) {
      url += '&latitude=${currentPosition!.latitude}&longitude=${currentPosition!.longitude}';
    }
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List items = data['items'] ?? [];
        final int totalCount = data['total_count'] ?? 0;
        List<MedicalFacility> newFacilities = items.map((e) => MedicalFacility.fromJson(e)).toList();
        if (currentPosition != null) {
          for (var facility in newFacilities) {
            double? lat = parseCoordinate(facility.wgs84Lat);
            double? lon = parseCoordinate(facility.wgs84Lon);
            if (lat != null && lon != null) {
              facility.distance = calculateDistance(
                currentPosition!.latitude,
                currentPosition!.longitude,
                lat,
                lon,
              );
            } else {
              facility.distance = double.infinity;
            }
          }
          newFacilities.sort((a, b) {
            if (a.distance == null && b.distance == null) return 0;
            if (a.distance == null) return 1;
            if (b.distance == null) return -1;
            if (a.distance == double.infinity && b.distance == double.infinity) return 0;
            if (a.distance == double.infinity) return 1;
            if (b.distance == double.infinity) return -1;
            return a.distance!.compareTo(b.distance!);
          });
        }
        setState(() {
          facilities = newFacilities;
          _totalCount = totalCount;
        });
      } else {
        setState(() {
          facilities = [];
          _totalCount = 0;
        });
      }
    } catch (e) {
      setState(() {
        facilities = [];
        _totalCount = 0;
      });
    }
  }

  Future<void> _showNearbyHospitals() async {
    if (!mounted) return;
    setState(() { isLoading = true; });
    try {
      final appState = context.read<AppState>();
      List<MedicalFacility>? cachedHospitals = appState.hospitals;
      
      if (cachedHospitals == null || cachedHospitals.isEmpty) {
        throw Exception('hospital.no_nearby'.tr());
      }

      if (mounted) {
        setState(() {
          facilities = List.from(cachedHospitals);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { 
          facilities = [];
          isLoading = false; 
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()))
        );
      }
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  double? parseCoordinate(String? coord) {
    if (coord == null || coord.isEmpty) return null;
    try {
      return double.parse(coord);
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadNextPage() async {
    if (_isPaginating || isLoading) return;
    setState(() {
      _isPaginating = true;
      _currentPage += 1;
    });
    try {
      if (_tabController.index == 0) {
        // 내 주변 탭: 추가 페이지 없음 (필요시 서버 API에 맞게 구현)
        // await _showNearbyHospitals();
      } else if (_searchController.text.trim().isNotEmpty) {
        // 검색어가 있을 때
        await _fetchData(pageNo: _currentPage);
      } else {
        // 진료과목 탭
        await _fetchDataBySubject(subject: subjects[_tabController.index], pageNo: _currentPage);
      }
    } catch (e) {
      // 에러 처리
    } finally {
      setState(() {
        _isPaginating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('hospital_search'.tr()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'search_hint'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _performSearch,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          Container(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: subjects.length,
              itemBuilder: (context, idx) {
                final selected = _tabController.index == idx;
                return GestureDetector(
                  onTap: () {
                    _tabController.animateTo(idx);
                    if (idx == 0) {
                      _showNearbyHospitals();
                    } else {
                      _searchBySubject(subjects[idx]);
                    }
                  },
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
          ),
          Expanded(
            child: isLoading && facilities.isEmpty
                ? Center(child: CircularProgressIndicator())
                : facilities.isEmpty
                ? Center(child: Text('no_result'.tr()))
                : ListView.builder(
              controller: _scrollController,
              itemCount: facilities.length + (_isPaginating ? 1 : 0),
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
                  distanceText = formatDistance(f.distance!);
                }
                return MedicalFacilityCard(
                  facility: f,
                  distanceText: distanceText,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicalFacilityDetailPage(facility: f),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.round()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }
}