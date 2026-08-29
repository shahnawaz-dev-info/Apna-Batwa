import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/dashboard/presentation/providers/dashboard_providers.dart';
import '../utils/formatters.dart';

class CsvExportService {
  static final CsvExportService instance = CsvExportService._internal();
  CsvExportService._internal();

  Future<void> exportTransactionsCsv({
    required List<CombinedTransactionItem> transactions,
  }) async {
    final List<List<dynamic>> rows = [
      ['Date', 'Type', 'Category / Title', 'Amount (PKR)', 'Note'],
    ];

    for (final t in transactions) {
      final formattedAmount = (t.amountCents / 100.0).toStringAsFixed(2);
      rows.add([
        CurrencyFormatter.formatDate(t.date),
        t.type.toUpperCase(),
        t.title,
        formattedAmount,
        t.note ?? '',
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final filename = 'ApnaBatwa_Transactions_${DateTime.now().millisecondsSinceEpoch}.csv';

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsString(csvData);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Apna Batwa CSV Transactions',
      text: 'CSV Export from Apna Batwa.',
    );
  }
}
