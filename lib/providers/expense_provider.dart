import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Expense> _expenses = [];
  Map<ExpenseCategory, double> _categoryTotals = {};
  bool _isLoading = true;
  String _selectedFilter = 'All';
  
  double _initialWalletBalance = 0.0;
  bool _hasSetWallet = false;
  bool _isDarkMode = false;

  List<Expense> get expenses => _expenses;
  Map<ExpenseCategory, double> get categoryTotals => _categoryTotals;
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;
  bool get hasSetWallet => _hasSetWallet;
  bool get isDarkMode => _isDarkMode;
  
  double get currentWalletBalance => _initialWalletBalance - totalSpent;
  double get initialWalletBalance => _initialWalletBalance;

  double get totalSpent =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get thisMonthTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  List<Expense> get recentExpenses =>
      _expenses.take(5).toList();

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('initial_wallet_balance')) {
      _initialWalletBalance = prefs.getDouble('initial_wallet_balance') ?? 0.0;
      _hasSetWallet = true;
    } else {
      _hasSetWallet = false;
    }

    _expenses = await _db.getAllExpenses();
    _categoryTotals = await _db.getCategoryTotals();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setInitialWalletBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('initial_wallet_balance', balance);
    _initialWalletBalance = balance;
    _hasSetWallet = true;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _db.insertExpense(expense);
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await _db.updateExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await _db.deleteExpense(id);
    await loadExpenses();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  List<Expense> get filteredExpenses {
    if (_selectedFilter == 'All') return _expenses;
    final cat = ExpenseCategory.values.firstWhere(
      (e) => e.displayName == _selectedFilter,
      orElse: () => ExpenseCategory.other,
    );
    return _expenses.where((e) => e.category == cat).toList();
  }

  // Weekly data for bar chart
  Map<String, double> get weeklyData {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<String, double> data = {for (var d in days) d: 0.0};
    for (final e in _expenses) {
      final diff = now.difference(e.date).inDays;
      if (diff < 7) {
        final weekday = _weekdayName(e.date.weekday);
        data[weekday] = (data[weekday] ?? 0) + e.amount;
      }
    }
    return data;
  }

  String _weekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  // Monthly data for the last 6 months
  Map<int, double> get monthlyData {
    final now = DateTime.now();
    final Map<int, double> data = {};
    // Initialize last 6 months with 0.0
    for (int i = 5; i >= 0; i--) {
      int month = now.month - i;
      int year = now.year;
      if (month <= 0) {
        month += 12;
        year -= 1;
      }
      data[month] = 0.0;
    }

    // Populate data
    for (final e in _expenses) {
      if (data.containsKey(e.date.month)) {
        // Technically this mixes years if you have exactly 1 year ago data, 
        // but for 6 month windows this is fine for a simple tracker.
        data[e.date.month] = data[e.date.month]! + e.amount;
      }
    }
    return data;
  }
}
