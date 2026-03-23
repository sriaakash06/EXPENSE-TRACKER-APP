import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';

class ExportService {
  static Future<void> exportToExcel(List<Expense> expenses, {String title = 'Expenses Export', double budget = 0, double remaining = 0}) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Expenses'];
    
    // Title row
    sheet.appendRow([TextCellValue(title)]);
    sheet.appendRow([]); // spacer

    double totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
    sheet.appendRow([TextCellValue('Budget'), DoubleCellValue(budget)]);
    sheet.appendRow([TextCellValue('Total Expenses'), DoubleCellValue(totalSpent)]);
    sheet.appendRow([TextCellValue('Remaining Balance'), DoubleCellValue(remaining)]);
    sheet.appendRow([]); // spacer

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
    final path = '${dir.path}/${title.replaceAll(' ', '_')}.xlsx';
    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      
      await Share.shareXFiles([XFile(path)], text: title);
    }
  }

  static Future<void> exportToPdf(List<Expense> expenses, {String title = 'Expense Report', double budget = 0, double remaining = 0}) async {
    double totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Report Generated: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
              pw.SizedBox(height: 15),
              pw.Text('Budget: Rs. ${budget.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Text('Total Expenses: Rs. ${totalSpent.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Text('Remaining Balance: Rs. ${remaining.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
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
    final filename = title.replaceAll(' ', '_');
    final path = '${dir.path}/$filename.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    
    await Share.shareXFiles([XFile(path)], text: title);
  }
}
