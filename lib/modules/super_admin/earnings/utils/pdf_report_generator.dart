import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../../../../shared/utils/app_navigator.dart';
import '../../../../../shared/utils/pdf_saver_stub.dart'
    if (dart.library.html) '../../../../../shared/utils/pdf_saver_web.dart'
    if (dart.library.io) '../../../../../shared/utils/pdf_saver_io.dart';

class PdfReportGenerator {
  static pw.Font? _arabicFont;
  static pw.Font? _arabicFontBold;

  static Future<String?> generateEarningsReport({
    required List<Map<String, dynamic>> earnings,
    required double totalSaEarnings,
    required double totalServiceFees,
    required double totalCommissions,
    required double totalDeliveryFees,
    required double totalVendorPayouts,
    required double thisMonthEarnings,
    required int totalOrders,
    DateTime? fromDate,
    DateTime? toDate,
    required String adminName,
  }) async {
    try {
      final pdf = pw.Document();

      final primaryOrange = PdfColor.fromHex('#F37A20');
      final cardDark = PdfColor.fromHex('#222327');
      final successColor = PdfColor.fromHex('#4CAF50');

      final fmt = NumberFormat.currency(symbol: 'ILS ', decimalDigits: 2);
      final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final isAr = AppNavigator.currentLocale.languageCode == 'ar';

      if (_arabicFont == null) {
        try {
          final res = await http.get(Uri.parse('https://raw.githubusercontent.com/google/fonts/main/ofl/tajawal/Tajawal-Regular.ttf'));
          if (res.statusCode == 200) {
            _arabicFont = pw.Font.ttf(res.bodyBytes.buffer.asByteData());
          }
          final resBold = await http.get(Uri.parse('https://raw.githubusercontent.com/google/fonts/main/ofl/tajawal/Tajawal-Bold.ttf'));
          if (resBold.statusCode == 200) {
            _arabicFontBold = pw.Font.ttf(resBold.bodyBytes.buffer.asByteData());
          }
        } catch (_) {}
      }

      String rangeText = isAr ? 'كل الوقت' : 'All Time';
      if (fromDate != null && toDate != null) {
        final dateFmt = DateFormat('dd MMM yyyy');
        rangeText = "${dateFmt.format(fromDate)} ${isAr ? 'إلى' : 'to'} ${dateFmt.format(toDate)}";
      }

      final theme = pw.ThemeData.withFont(
        base: isAr ? (_arabicFont ?? pw.Font.helvetica()) : pw.Font.helvetica(),
        bold: isAr
            ? (_arabicFontBold ?? _arabicFont ?? pw.Font.helveticaBold())
            : pw.Font.helveticaBold(),
        // Always include Arabic font as fallback so Arabic vendor names
        // are rendered correctly even when the PDF language is English.
        fontFallback: _arabicFont != null
            ? [_arabicFont!, if (_arabicFontBold != null) _arabicFontBold!]
            : [],
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          theme: theme,
          header: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(isAr ? 'إدارة الطلبات' : 'Order Gaza',
                        style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryOrange)),
                    pw.Text(isAr ? 'التقرير المالي' : 'Financial Report',
                        style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(color: primaryOrange),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(isAr ? 'طبع بواسطة: $adminName' : 'Printed by: $adminName',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(isAr ? 'التاريخ: $timestamp' : 'Date: $timestamp',
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text(isAr ? 'المدة: $rangeText' : 'Duration: $rangeText',
                    style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700)),
                pw.SizedBox(height: 20),
              ],
            );
          },
          build: (context) {
            return [
              // Summary Table
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: cardDark,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: pw.WrapAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem(isAr ? 'أرباح الشركة' : 'Company Profit', fmt.format(totalSaEarnings), primaryOrange),
                    _buildSummaryItem(isAr ? 'رسوم الخدمة' : 'Service Fees', fmt.format(totalServiceFees), PdfColors.purple300),
                    _buildSummaryItem(isAr ? 'العمولات' : 'Commissions', fmt.format(totalCommissions), PdfColors.amber),
                    _buildSummaryItem(isAr ? 'رسوم التوصيل' : 'Delivery Fees', fmt.format(totalDeliveryFees), PdfColors.lightBlue),
                    _buildSummaryItem(isAr ? 'مستحقات المتاجر' : 'Vendor Payouts', fmt.format(totalVendorPayouts), PdfColors.orange200),
                    _buildSummaryItem(isAr ? 'أرباح الشهر' : 'This Month Profit', fmt.format(thisMonthEarnings), successColor),
                    _buildSummaryItem(isAr ? 'إجمالي الطلبات' : 'Total Orders', '$totalOrders', PdfColors.blue),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              pw.Text(isAr ? 'سجل الأرباح' : 'Earnings Record',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              // Data Table
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: primaryOrange),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignments: {
                  0: isAr ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                  1: isAr ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: isAr ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
                  4: isAr ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
                  5: isAr ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
                  6: pw.Alignment.center,
                },
                data: [
                  isAr
                    ? ['رقم الطلب', 'المتجر', 'التاريخ', 'رسوم الخدمة', 'العمولة', 'إجمالي الربح', 'الحالة']
                    : ['Order #', 'Vendor', 'Date', 'Service Fee', 'Commission', 'SA Earning', 'Status'],
                  ...earnings.map((e) {
                    final serviceFee = double.tryParse(e['service_fee_earned']?.toString() ?? '0') ?? 0;
                    final commission = double.tryParse(e['commission_earned']?.toString() ?? '0') ?? 0;
                    final saEarning = (e['sa_earning'] != null)
                        ? (double.tryParse(e['sa_earning'].toString()) ?? serviceFee + commission)
                        : serviceFee + commission;
                    final date = e['earned_at'] ?? e['date'] ?? e['created_at'] ?? '';
                    final vendorName = e['vendor_name'] ?? '';
                    final status = (e['is_collected'] ?? 0) == 1
                        ? (isAr ? 'مُحصل' : 'Collected')
                        : (isAr ? 'قيد الانتظار' : 'Pending');
                    return [
                      e['order_number'] ?? '',
                      vendorName,
                      date,
                      fmt.format(serviceFee),
                      fmt.format(commission),
                      fmt.format(saEarning),
                      status,
                    ];
                  }),
                ],
              ),
            ];
          },
          footer: (context) {
            return pw.Container(
              alignment: isAr ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(isAr ? 'صفحة ${context.pageNumber} من ${context.pagesCount}' : 'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            );
          },
        ),
      );

      final bytes = await pdf.save();
      final timeFormatted = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final reportPrefix = isAr ? 'التقرير_المالي' : 'Financial_Report';
      final filename = "order-$reportPrefix-$timeFormatted.pdf";

      final path = await saveAndDownloadPdf(bytes, filename);
      return path;
    } catch (e) {
      assert(() { debugPrint('PDF Generation Error: $e'); return true; }());
      return null;
    }
  }

  static pw.Widget _buildSummaryItem(String title, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 10, color: PdfColors.white)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }
}
