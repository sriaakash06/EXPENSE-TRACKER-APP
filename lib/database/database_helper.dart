import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

/// A local persistence layer backed by SharedPreferences using JSON.
/// Works perfectly across Web, Windows, Android, and iOS without FFI configuration.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const String _key = 'expenses_data';

  Future<List<Expense>> getAllExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final expenses = list.map((e) => Expense.fromMap(e as Map<String, dynamic>)).toList();
      expenses.sort((a, b) => b.date.compareTo(a.date));
      return expenses;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(expenses.map((e) => e.toMap()).toList());
    await prefs.setString(_key, data);
  }

  Future<int> insertExpense(Expense expense) async {
    final expenses = await getAllExpenses();
    // Replace if exists
    expenses.removeWhere((e) => e.id == expense.id);
    expenses.add(expense);
    await _saveAll(expenses);
    return 1;
  }

  Future<int> updateExpense(Expense expense) async {
    return await insertExpense(expense);
  }

  Future<int> deleteExpense(String id) async {
    final expenses = await getAllExpenses();
    final initialLength = expenses.length;
    expenses.removeWhere((e) => e.id == id);
    if (expenses.length < initialLength) {
      await _saveAll(expenses);
      return 1;
    }
    return 0;
  }

  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async {
    final expenses = await getAllExpenses();
    return expenses.where((e) => e.category == category).toList();
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final expenses = await getAllExpenses();
    return expenses.where((e) => e.date.isAfter(start.subtract(const Duration(seconds: 1))) && 
                                 e.date.isBefore(end.add(const Duration(seconds: 1)))).toList();
  }

  Future<double> getTotalAmount() async {
    final expenses = await getAllExpenses();
    double total = 0.0;
    for (var e in expenses) {
      total += e.amount;
    }
    return total;
  }

  Future<Map<ExpenseCategory, double>> getCategoryTotals() async {
    final expenses = await getAllExpenses();
    final Map<ExpenseCategory, double> totals = {};
    for (var e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0.0) + e.amount;
    }
    return totals;
  }

  Future<void> clearAllExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove('initial_wallet_balance'); // Also reset budget
  }
}
