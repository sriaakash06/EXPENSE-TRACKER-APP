import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';

class ExportService {
  static Future<void> exportToExcel(List<Expense> expenses) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Expenses'];
    
    // Header
    sheet.appendRow([
      TextCellValue('Title'),
      TextCellValue('Amount'),
      TextCellValue('Category'),
      TextCellValue('Date'),
      TextCellValue('Note')
    ]);
    
    // Data
    for (var e in expenses) {
      sheet.appendRow([
        TextCellValue(e.title),
        DoubleCellValue(e.amount),
        TextCellValue(e.category.displayName),
        TextCellValue(DateFormat('yyyy-MM-dd').format(e.date)),
        TextCellValue(e.note ?? '')
      ]);
    }
    
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/expenses_export.xlsx';
    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      
      await Share.shareXFiles([XFile(path)], text: 'My Expenses Export');
    }
  }

  static Future<void> exportToPdf(List<Expense> expenses) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Expense Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Title', 'Amount', 'Category', 'Date'],
                data: expenses.map((e) => [
                  e.title,
                  '${e.amount.toStringAsFixed(2)}',
                  e.category.displayName,
                  DateFormat('yyyy-MM-dd').format(e.date)
                ]).toList(),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/expenses_report.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    
    await Share.shareXFiles([XFile(path)], text: 'My Expenses PDF Report');
  }
}
