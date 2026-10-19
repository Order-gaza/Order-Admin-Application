import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';
import '../utils/pdf_report_generator.dart';

final saEarningsProvider =
    ChangeNotifierProvider<SaEarningsController>((ref) {
  return SaEarningsController.to;
});

class SaEarningsController extends ChangeNotifier {
  static SaEarningsController? _instance;
  static SaEarningsController get to => _instance ??= SaEarningsController();

  bool isLoading = false;
  List<Map<String, dynamic>> earnings = [];

  // Summary stats — SA-specific
  double totalSaEarnings = 0.0;
  double totalServiceFees = 0.0;
  double totalCommissions = 0.0;
  double totalCollected = 0.0;
  double totalUncollected = 0.0;
  int totalOrders = 0;
  double avgPerOrder = 0.0;
  double thisMonthEarnings = 0.0;
  double thisMonthServiceFees = 0.0;
  double thisMonthCommissions = 0.0;
  double totalDeliveryFees = 0.0;
  double totalVendorPayouts = 0.0;

  // Per-vendor breakdown
  List<Map<String, dynamic>> vendorSummary = [];

  // Date filter
  DateTime? fromDate;
  DateTime? toDate;

  SaEarningsController() {
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading = true;
    notifyListeners();
    try {
      // Build shared date params once — used for BOTH summary and list calls
      Map<String, String>? dateParams;
      if (fromDate != null && toDate != null) {
        dateParams = {
          'from': fromDate!.toIso8601String().split('T')[0],
          'to': toDate!.toIso8601String().split('T')[0],
        };
      }

      // ── Fetch summary (pass date params so stats are period-filtered) ──
      final summaryRes = await ApiProvider.get(
        ApiEndpoints.saEarningsGetSummary,
        queryParams: dateParams,
      );
      if (summaryRes.success && summaryRes.data != null) {
        final d = summaryRes.data as Map<String, dynamic>;
        totalSaEarnings =
            double.tryParse(d['total_sa_earnings']?.toString() ?? '0') ?? 0;
        totalServiceFees =
            double.tryParse(d['total_service_fees']?.toString() ?? '0') ?? 0;
        totalCommissions =
            double.tryParse(d['total_commissions']?.toString() ?? '0') ?? 0;
        totalCollected =
            double.tryParse(d['total_collected']?.toString() ?? '0') ?? 0;
        totalUncollected =
            double.tryParse(d['total_uncollected']?.toString() ?? '0') ?? 0;
        totalOrders =
            int.tryParse(d['total_orders']?.toString() ?? '0') ?? 0;
        avgPerOrder =
            double.tryParse(d['avg_per_order']?.toString() ?? '0') ?? 0;
        thisMonthEarnings =
            double.tryParse(d['this_month']?.toString() ?? '0') ?? 0;
        thisMonthServiceFees =
            double.tryParse(d['this_month_service_fees']?.toString() ?? '0') ??
                0;
        thisMonthCommissions =
            double.tryParse(d['this_month_commissions']?.toString() ?? '0') ??
                0;
        totalDeliveryFees =
            double.tryParse(d['total_delivery_fees']?.toString() ?? '0') ?? 0;
        totalVendorPayouts =
            double.tryParse(d['total_vendor_payouts']?.toString() ?? '0') ?? 0;

        if (d['vendor_summary'] != null) {
          vendorSummary =
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
          earnings =
              List<Map<String, dynamic>>.from(data['earnings'] as List);
        } else if (data is List) {
          earnings = List<Map<String, dynamic>>.from(data);
        }
      }
    } finally {
      isLoading = false;
      notifyListeners();
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
      fromDate = picked.start;
      toDate = picked.end;
      notifyListeners();
      await fetchAll();
    }
  }

  void clearDateFilter() {
    fromDate = null;
    toDate = null;
    notifyListeners();
    fetchAll();
  }

  Future<void> markCollected(String earningId) async {
    final res = await ApiProvider.post(ApiEndpoints.saEarningsMarkCollected,
        body: {'earning_id': earningId});
    if (res.success) {
      await fetchAll();
      AppNavigator.snackbar('Collected'.tr, 'Marked as collected'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
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
      AppNavigator.snackbar('Collected'.tr, 'All marked as collected'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> downloadReport() async {
    final adminName =
        ApiProvider.storedUserName ?? 'Super Admin';
    AppNavigator.snackbar('Generating PDF'.tr, 'Please wait...'.tr,
        backgroundColor: const Color(0xFF2196F3),
        colorText: const Color(0xFFFFFFFF));

    final filepath = await PdfReportGenerator.generateEarningsReport(
      earnings: earnings,
      totalSaEarnings: totalSaEarnings,
      totalServiceFees: totalServiceFees,
      totalCommissions: totalCommissions,
      totalDeliveryFees: totalDeliveryFees,
      totalVendorPayouts: totalVendorPayouts,
      thisMonthEarnings: thisMonthEarnings,
      totalOrders: totalOrders,
      fromDate: fromDate,
      toDate: toDate,
      adminName: adminName,
    );

    if (filepath != null) {
      AppNavigator.snackbar(
          'Success'.tr,
          'Report saved to:\n@filepath'
              .trParams({'filepath': filepath}),
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 4));
    } else {
      AppNavigator.snackbar(
          'Error'.tr, 'Failed to save PDF. Check storage permissions.'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
