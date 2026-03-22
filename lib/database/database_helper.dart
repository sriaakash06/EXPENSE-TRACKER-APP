import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

/// A local persistence layer backed by SharedPreferences.
/// Stores expenses as a JSON array under the key [_kExpensesKey].
/// This gives full CRUD with data persistence across app restarts,
/// equivalent to a lightweight SQLite table.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const String _kExpensesKey = 'expenses_v1';

  // ────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────

  Future<List<Expense>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kExpensesKey);
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Expense.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeAll(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(expenses.map((e) => e.toMap()).toList());
    await prefs.setString(_kExpensesKey, encoded);
  }

  // ────────────────────────────────────────────────────────────────
  // Public API  (mirrors a typical SQLite helper)
  // ────────────────────────────────────────────────────────────────

  Future<int> insertExpense(Expense expense) async {
    final all = await _readAll();
    all.removeWhere((e) => e.id == expense.id); // upsert
    all.add(expense);
    await _writeAll(all);
    return 1;
  }

  Future<List<Expense>> getAllExpenses() async {
    final all = await _readAll();
    all.sort((a, b) => b.date.compareTo(a.date));
    return all;
  }

  Future<int> updateExpense(Expense expense) async {
    final all = await _readAll();
    final idx = all.indexWhere((e) => e.id == expense.id);
    if (idx == -1) return 0;
    all[idx] = expense;
    await _writeAll(all);
    return 1;
  }

  Future<int> deleteExpense(String id) async {
    final all = await _readAll();
    final before = all.length;
    all.removeWhere((e) => e.id == id);
    await _writeAll(all);
    return before - all.length;
  }

  Future<List<Expense>> getExpensesByCategory(
      ExpenseCategory category) async {
    final all = await getAllExpenses();
    return all.where((e) => e.category == category).toList();
  }

  Future<List<Expense>> getExpensesByDateRange(
      DateTime start, DateTime end) async {
    final all = await getAllExpenses();
    return all
        .where((e) =>
            e.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            e.date.isBefore(end.add(const Duration(seconds: 1))))
        .toList();
  }

  Future<double> getTotalAmount() async {
    final all = await getAllExpenses();
    return all.fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  Future<Map<ExpenseCategory, double>> getCategoryTotals() async {
    final all = await getAllExpenses();
    final Map<ExpenseCategory, double> totals = {};
    for (final e in all) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }
}
