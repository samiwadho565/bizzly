import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/auth/models/user_model.dart';
import 'package:bizly/services/local_storage.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/enum.dart';
import 'package:bizly/utils/app_colors.dart';

class HomeScreenController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var viewType = RevenueViewType.weekly.obs;

  late List<RevenueBar> weeklyData;
  late List<RevenueBar> monthlyData;
  late List<RevenueBar> yearlyData;

  final RxList<BusinessModel> businesses = <BusinessModel>[].obs;
  final RxBool isBusinessesLoading = false.obs;
  final RxString businessesError = ''.obs;
  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxString imageCacheBuster = ''.obs;

  @override
  void onInit() {
    super.onInit();

    weeklyData = [
      RevenueBar(day: "Mon", value: 40),
      RevenueBar(day: "Tue", value: 55),
      RevenueBar(day: "Wed", value: 75),
      RevenueBar(day: "Thu", value: 85),
      RevenueBar(day: "Fri", value: 100),
      RevenueBar(day: "Sat", value: 80),
      RevenueBar(day: "Sun", value: 60),
    ];

    monthlyData = [
      RevenueBar(day: "Jan", value: 60),
      RevenueBar(day: "Feb", value: 75),
      RevenueBar(day: "Mar", value: 90),
      RevenueBar(day: "Apr", value: 70),
      RevenueBar(day: "May", value: 110),
      RevenueBar(day: "Jun", value: 95),
      RevenueBar(day: "Jul", value: 85),
      RevenueBar(day: "Aug", value: 75),
      RevenueBar(day: "Sep", value: 70),
      RevenueBar(day: "Oct", value: 110),
      RevenueBar(day: "Nov", value: 95),
      RevenueBar(day: "Dec", value: 90),
    ];

    yearlyData = [
      RevenueBar(day: "2024", value: 80),
      RevenueBar(day: "2025", value: 100),
      RevenueBar(day: "2026", value: 200),
    ];

    // Default first bar selected for each
    weeklyData[0].isSelected.value = true;
    monthlyData[0].isSelected.value = true;
    yearlyData[0].isSelected.value = true;

    _bootstrapUser();
    fetchBusinesses();
  }

  Future<void> _bootstrapUser() async {
    await _loadUser();
    await _fetchUserProfile();
  }

  List<RevenueBar> get currentData {
    switch (viewType.value) {
      case RevenueViewType.weekly:
        return weeklyData;
      case RevenueViewType.monthly:
        return monthlyData;
      case RevenueViewType.yearly:
        return yearlyData;
    }
  }

  String get title {
    switch (viewType.value) {
      case RevenueViewType.weekly:
        return "Weekly Revenue";
      case RevenueViewType.monthly:
        return "Monthly Revenue";
      case RevenueViewType.yearly:
        return "Yearly Revenue";
    }
  }

  void selectBar(RevenueBar bar) {
    for (var b in currentData) {
      b.isSelected.value = false;
    }
    bar.isSelected.value = true;
    update(); // Update GetX observers
  }

  void changeView(String value) {
    switch (value) {
      case "Weekly":
        viewType.value = RevenueViewType.weekly;
        break;
      case "Monthly":
        viewType.value = RevenueViewType.monthly;
        break;
      case "Yearly":
        viewType.value = RevenueViewType.yearly;
        break;
    }
  }

  Future<void> fetchBusinesses() async {
    if (isBusinessesLoading.value) return;
    isBusinessesLoading.value = true;
    businessesError.value = '';

    ApiResponse response = await ApiService().get(
      AppUrls.getAllBusinesses,
      isAuth: true,
    );

    if (response.success && response.data is List) {
      final List<dynamic> items = response.data as List<dynamic>;
      businesses.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map((json) => BusinessModel.fromJson(json))
            .toList(),
      );
    } else {
      businesses.clear();
      businessesError.value = response.message;
    }

    isBusinessesLoading.value = false;
  }

  Future<void> _loadUser() async {
    final UserModel? local = await LocalStorage.getUser();
    if (local != null) {
      user.value = local;
    }
  }

  Future<void> _fetchUserProfile() async {
    final String? previousImage = user.value?.imageUrl;
    final ApiResponse response = await ApiService().get(
      AppUrls.profile,
      isAuth: true,
    );
    if (response.success && response.data is Map) {
      final Map<String, dynamic> map =
          Map<String, dynamic>.from(response.data as Map);
      final Map<String, dynamic> payload =
          map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
      final UserModel updated = UserModel.fromJson(payload);
      user.value = updated;
      if (_didImageChange(previousImage, updated.imageUrl)) {
        _bustCache();
      }
      await LocalStorage.saveUser(updated);
    }
  }

  void setUser(UserModel updated) {
    final String? previousImage = user.value?.imageUrl;
    user.value = updated;
    if (_didImageChange(previousImage, updated.imageUrl)) {
      _bustCache();
    }
  }

  String? get displayImageUrl {
    final String? url = user.value?.imageUrl;
    if (url == null || url.isEmpty) return null;
    final String buster = imageCacheBuster.value;
    if (buster.isEmpty) return url;
    final String separator = url.contains('?') ? '&' : '?';
    return '$url${separator}v=$buster';
  }

  void _bustCache() {
    imageCacheBuster.value =
        DateTime.now().millisecondsSinceEpoch.toString();
  }

  bool _didImageChange(String? previous, String? current) {
    final String before = (previous ?? '').trim();
    final String after = (current ?? '').trim();
    return before != after;
  }
}



class RevenueBar {
  final String day;
  final double value;
  RxBool isSelected;

  RevenueBar({
    required this.day,
    required this.value,
    bool isSelected = false, // default value
  }) : isSelected = isSelected.obs;
}
