import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  transport,
  shopping,
  health,
  entertainment,
  education,
  utilities,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.health:
        return 'Health';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.transport:
        return Icons.directions_car_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.health:
        return Icons.favorite_rounded;
      case ExpenseCategory.entertainment:
        return Icons.movie_rounded;
      case ExpenseCategory.education:
        return Icons.school_rounded;
      case ExpenseCategory.utilities:
        return Icons.bolt_rounded;
      case ExpenseCategory.other:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return const Color(0xFFFF6B6B);
      case ExpenseCategory.transport:
        return const Color(0xFF4ECDC4);
      case ExpenseCategory.shopping:
        return const Color(0xFFFFE66D);
      case ExpenseCategory.health:
        return const Color(0xFFFF8B94);
      case ExpenseCategory.entertainment:
        return const Color(0xFFA78BFA);
      case ExpenseCategory.education:
        return const Color(0xFF60A5FA);
      case ExpenseCategory.utilities:
        return const Color(0xFF34D399);
      case ExpenseCategory.other:
        return const Color(0xFFFB923C);
    }
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? note;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ExpenseCategory.other,
      ),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
