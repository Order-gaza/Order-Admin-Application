import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../app/constants/app_constants.dart';
import '../utils/pdf_report_generator.dart';

class SaEarningsController extends GetxController {
  final isLoading = false.obs;
  final earnings = <Map<String, dynamic>>[].obs;

  // Summary stats — SA-specific
  final totalSaEarnings = 0.0.obs;
  final totalServiceFees = 0.0.obs;
  final totalCommissions = 0.0.obs;
  final totalCollected = 0.0.obs;
  final totalUncollected = 0.0.obs;
  final totalOrders = 0.obs;
  final avgPerOrder = 0.0.obs;
  final thisMonthEarnings = 0.0.obs;
  final thisMonthServiceFees = 0.0.obs;
  final thisMonthCommissions = 0.0.obs;
  final totalDeliveryFees = 0.0.obs;
  final totalVendorPayouts = 0.0.obs;

  // Per-vendor breakdown
  final vendorSummary = <Map<String, dynamic>>[].obs;

  // Date filter
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      // Build shared date params once — used for BOTH summary and list calls
      Map<String, String>? dateParams;
      if (fromDate.value != null && toDate.value != null) {
        dateParams = {
          'from': fromDate.value!.toIso8601String().split('T')[0],
          'to': toDate.value!.toIso8601String().split('T')[0],
        };
      }

      // ── Fetch summary (pass date params so stats are period-filtered) ──
      final summaryRes = await ApiProvider.get(
        ApiEndpoints.saEarningsGetSummary,
        queryParams: dateParams,
      );
      if (summaryRes.success && summaryRes.data != null) {
        final d = summaryRes.data as Map<String, dynamic>;
        totalSaEarnings.value =
            double.tryParse(d['total_sa_earnings']?.toString() ?? '0') ?? 0;
        totalServiceFees.value =
            double.tryParse(d['total_service_fees']?.toString() ?? '0') ?? 0;
        totalCommissions.value =
            double.tryParse(d['total_commissions']?.toString() ?? '0') ?? 0;
        totalCollected.value =
            double.tryParse(d['total_collected']?.toString() ?? '0') ?? 0;
        totalUncollected.value =
            double.tryParse(d['total_uncollected']?.toString() ?? '0') ?? 0;
        totalOrders.value =
            int.tryParse(d['total_orders']?.toString() ?? '0') ?? 0;
        avgPerOrder.value =
            double.tryParse(d['avg_per_order']?.toString() ?? '0') ?? 0;
        thisMonthEarnings.value =
            double.tryParse(d['this_month']?.toString() ?? '0') ?? 0;
        thisMonthServiceFees.value =
            double.tryParse(d['this_month_service_fees']?.toString() ?? '0') ??
                0;
        thisMonthCommissions.value =
            double.tryParse(d['this_month_commissions']?.toString() ?? '0') ??
                0;
        totalDeliveryFees.value =
            double.tryParse(d['total_delivery_fees']?.toString() ?? '0') ?? 0;
        totalVendorPayouts.value =
            double.tryParse(d['total_vendor_payouts']?.toString() ?? '0') ?? 0;

        if (d['vendor_summary'] != null) {
          vendorSummary.value =
              List<Map<String, dynamic>>.from(d['vendor_summary'] as List);
        }
      }

      // ── Fetch earnings list ──
      final String listUrl = dateParams != null
          ? ApiEndpoints.saEarningsGetByDateRange
          : ApiEndpoints.saEarningsGetAll;
      final listRes = await ApiProvider.get(listUrl, queryParams: dateParams);
      if (listRes.success && listRes.data != null) {
        final data = listRes.data;
        if (data is Map && data['earnings'] != null) {
          earnings.value =
              List<Map<String, dynamic>>.from(data['earnings'] as List);
        } else if (data is List) {
          earnings.value = List<Map<String, dynamic>>.from(data);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFF37A20),
            onPrimary: Colors.white,
            surface: Color(0xFF2C2C2C),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      fromDate.value = picked.start;
      toDate.value = picked.end;
      await fetchAll();
    }
  }

  void clearDateFilter() {
    fromDate.value = null;
    toDate.value = null;
    fetchAll();
  }

  Future<void> markCollected(String earningId) async {
    final res = await ApiProvider.post(ApiEndpoints.saEarningsMarkCollected,
        body: {'earning_id': earningId});
    if (res.success) {
      await fetchAll();
      Get.snackbar('Collected'.tr, 'Marked as collected'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> markBulkCollected() async {
    final res = await ApiProvider.post(
        ApiEndpoints.saEarningsMarkBulkCollected,
        body: {});
    if (res.success) {
      await fetchAll();
      Get.snackbar('Collected'.tr, 'All marked as collected'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> downloadReport() async {
    final adminName =
        ApiProvider.storedUserName ?? 'Super Admin';
    Get.snackbar('Generating PDF'.tr, 'Please wait...'.tr,
        backgroundColor: const Color(0xFF2196F3),
        colorText: const Color(0xFFFFFFFF));

    final filepath = await PdfReportGenerator.generateEarningsReport(
      earnings: earnings,
      totalSaEarnings: totalSaEarnings.value,
      totalServiceFees: totalServiceFees.value,
      totalCommissions: totalCommissions.value,
      totalDeliveryFees: totalDeliveryFees.value,
      totalVendorPayouts: totalVendorPayouts.value,
      thisMonthEarnings: thisMonthEarnings.value,
      totalOrders: totalOrders.value,
      fromDate: fromDate.value,
      toDate: toDate.value,
      adminName: adminName,
    );

    if (filepath != null) {
      Get.snackbar(
          'Success'.tr,
          'Report saved to:\n@filepath'
              .trParams({'filepath': filepath}),
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 4));
    } else {
      Get.snackbar(
          'Error'.tr, 'Failed to save PDF. Check storage permissions.'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
