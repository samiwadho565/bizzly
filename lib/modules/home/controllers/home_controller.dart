import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/auth/models/user_model.dart';
import 'package:bizly/modules/vouchers/models/voucher_model.dart';
import 'package:bizly/modules/home/models/dashboard_model.dart';
import 'package:bizly/services/local_storage.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_colors.dart';

class HomeScreenController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final RxList<BusinessModel> businesses = <BusinessModel>[].obs;
  final RxBool isBusinessesLoading = false.obs;
  final RxString businessesError = ''.obs;
  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxString imageCacheBuster = ''.obs;

  // ── Pending Approvals ─────────────────────────────────────────
  final RxList<VoucherModel> pendingApprovals = <VoucherModel>[].obs;
  int get pendingCount => pendingApprovals.length;

  // ── Dashboard ─────────────────────────────────────────────────
  final Rxn<DashboardModel> dashboard = Rxn<DashboardModel>();
  final RxBool isDashboardLoading = false.obs;

  // ── Dashboard business filter (confirmed working via ?business_id=) ──
  final Rxn<BusinessModel> dashboardFilterBusiness = Rxn<BusinessModel>();

  @override
  void onInit() {
    super.onInit();

    _bootstrapUser();
    fetchBusinesses();
    fetchPendingApprovals();
    fetchDashboard();
  }

  Future<void> _bootstrapUser() async {
    await _loadUser();
    await _fetchUserProfile();
  }

  void applyDashboardBusiness(BusinessModel? business) {
    dashboardFilterBusiness.value = business;
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    isDashboardLoading.value = true;
    final String url = dashboardFilterBusiness.value?.id != null
        ? '${AppUrls.dashboard}?business_id=${dashboardFilterBusiness.value!.id}'
        : AppUrls.dashboard;
    final ApiResponse res = await ApiService().get(
      url,
      isAuth: true,
    );
    isDashboardLoading.value = false;
    if (res.success && res.data is Map) {
      dashboard.value = DashboardModel.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    }
  }

  Future<void> fetchPendingApprovals() async {
    final ApiResponse res = await ApiService().get(
      AppUrls.vouchersPendingApprovals,
      isAuth: true,
    );
    if (res.success) {
      final List<dynamic> raw = res.data is List
          ? res.data as List
          : (res.data is Map && res.data['data'] is List
              ? res.data['data'] as List
              : []);
      pendingApprovals.assignAll(
        raw.whereType<Map>()
            .map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
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



