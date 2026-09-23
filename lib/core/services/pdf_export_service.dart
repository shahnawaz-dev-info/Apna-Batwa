import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/dashboard/presentation/providers/dashboard_providers.dart';
import '../../features/reports/presentation/providers/reports_providers.dart';
import '../../features/khata/presentation/providers/khata_providers.dart';
import '../utils/formatters.dart';

class PdfExportService {
  static final PdfExportService instance = PdfExportService._internal();
  PdfExportService._internal();

  Future<void> exportReportsPdf({
    required ReportTimeRange range,
    required List<CategoryExpenseReport> categoryReport,
    required List<MonthlyTrendPoint> trendPoints,
    required KhataSummaryData khataSummary,
  }) async {
    final pdf = pw.Document();
    final nowStr = CurrencyFormatter.formatDate(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Branding Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Apna Batwa',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.Text(
                      'Financial Analytics & Reports',
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Period: ${range.label}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Generated: $nowStr', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 16),

            // Section 1: Category Expense Breakdown
            pw.Text(
              'Category Expense Breakdown',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (categoryReport.isEmpty)
              pw.Text('No expense records in selected period.', style: const pw.TextStyle(color: PdfColors.grey600))
            else
              pw.TableHelper.fromTextArray(
                headers: ['Category', 'Amount (PKR)', 'Percentage'],
                data: categoryReport.map((c) {
                  return [
                    c.categoryName,
                    CurrencyFormatter.formatCents(c.totalCents),
                    '${c.percentage.toStringAsFixed(1)}%',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              ),
            pw.SizedBox(height: 20),

            // Section 2: Income vs Expense Trend
            pw.Text(
              'Monthly Income vs Expense Trend',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (trendPoints.isEmpty)
              pw.Text('No trend data available.', style: const pw.TextStyle(color: PdfColors.grey600))
            else
              pw.TableHelper.fromTextArray(
                headers: ['Month', 'Income (PKR)', 'Expenses (PKR)', 'Net Savings'],
                data: trendPoints.map((t) {
                  final net = t.incomeCents - t.expenseCents;
                  return [
                    t.label,
                    CurrencyFormatter.formatCents(t.incomeCents),
                    CurrencyFormatter.formatCents(t.expenseCents),
                    CurrencyFormatter.formatCents(net),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              ),
            pw.SizedBox(height: 20),

            // Section 3: Khata Net Position
            pw.Text(
              'Khata Summary (Borrowed & Lent)',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Metric', 'Amount (PKR)'],
              data: [
                ['You Owe (Total Borrowed Balance)', CurrencyFormatter.formatCents(khataSummary.totalBorrowedCents)],
                ['Others Owe You (Total Lent Balance)', CurrencyFormatter.formatCents(khataSummary.totalLentCents)],
                [
                  'Net Khata Position',
                  CurrencyFormatter.formatCents(khataSummary.netBalanceCents),
                ],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'ApnaBatwa_Financial_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  Future<void> exportTransactionsPdf({
    required List<CombinedTransactionItem> transactions,
    required String title,
  }) async {
    final pdf = pw.Document();
    final nowStr = CurrencyFormatter.formatDate(DateTime.now());

    int totalInc = 0;
    int totalExp = 0;
    for (final t in transactions) {
      if (t.type == 'income') {
        totalInc += t.amountCents;
      } else {
        totalExp += t.amountCents;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Apna Batwa',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.Text(
                      'Transaction History ($title)',
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Text('Generated: $nowStr', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 12),

            // Transactions Table
            if (transactions.isEmpty)
              pw.Text('No transactions match the selected filter.', style: const pw.TextStyle(color: PdfColors.grey600))
            else
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Type', 'Category / Title', 'Amount (PKR)', 'Note'],
                data: transactions.map((t) {
                  return [
                    CurrencyFormatter.formatDate(t.date),
                    t.type.toUpperCase(),
                    t.title,
                    CurrencyFormatter.formatCents(t.amountCents),
                    t.note ?? '-',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 6),
              ),

            pw.SizedBox(height: 16),
            // Totals Box
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Text('Total Income: ${CurrencyFormatter.formatCents(totalInc)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                  pw.Text('Total Expenses: ${CurrencyFormatter.formatCents(totalExp)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                  pw.Text('Net Flow: ${CurrencyFormatter.formatCents(totalInc - totalExp)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'ApnaBatwa_Transactions_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  Future<void> exportSingleTransactionReceiptPdf({
    required CombinedTransactionItem item,
    required String bankName,
  }) async {
    final pdf = pw.Document();
    final nowStr = DateFormatters.formatDateTime(item.date);
    final refId = 'BATWA-${item.id.toUpperCase().replaceAll('-', '').padRight(8).substring(0, 8)}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  bankName,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Official Transaction Receipt / Advice Slip',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 12),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 14),
                pw.Text(
                  'STATUS: SUCCESSFUL',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '${item.isIncome ? "+" : "-"}${CurrencyFormatter.formatCents(item.amountCents)}',
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                    color: item.isIncome ? PdfColors.green800 : PdfColors.red800,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Divider(thickness: 0.8, color: PdfColors.grey300),
                pw.SizedBox(height: 12),
                _buildReceiptRow('Reference ID', '#$refId'),
                _buildReceiptRow('Transaction Type', item.isIncome ? 'Income / Money In' : 'Expense / Money Out'),
                _buildReceiptRow('Category', item.title),
                _buildReceiptRow('Date & Time', nowStr),
                if (item.subtitle != null && item.subtitle!.isNotEmpty)
                  _buildReceiptRow('Note / Details', item.subtitle!),
                pw.Spacer(),
                pw.Divider(thickness: 0.8, color: PdfColors.grey300),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Generated securely by Apna Batwa Smart Wallet',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Receipt_$refId.pdf',
    );
  }

  pw.Widget _buildReceiptRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
