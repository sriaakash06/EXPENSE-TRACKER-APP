import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  transport,
  shopping,
  health,
  entertainment,
  education,
  electricity,
  home,
  insurance,
  marketing,
  internet,
  water,
  rent,
  gym,
  subscription,
  vacation,
  hotels,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.food: return 'Food';
      case ExpenseCategory.transport: return 'Travel';
      case ExpenseCategory.shopping: return 'Shopping';
      case ExpenseCategory.health: return 'Health';
      case ExpenseCategory.entertainment: return 'Entertainment';
      case ExpenseCategory.education: return 'Education';
      case ExpenseCategory.electricity: return 'Electricity';
      case ExpenseCategory.home: return 'Home';
      case ExpenseCategory.insurance: return 'Insurance';
      case ExpenseCategory.marketing: return 'Marketing';
      case ExpenseCategory.internet: return 'Internet';
      case ExpenseCategory.water: return 'Water';
      case ExpenseCategory.rent: return 'Rent';
      case ExpenseCategory.gym: return 'Gym';
      case ExpenseCategory.subscription: return 'Subscription';
      case ExpenseCategory.vacation: return 'Vacation';
      case ExpenseCategory.hotels: return 'Hotels';
      case ExpenseCategory.other: return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food: return Icons.restaurant_rounded;
      case ExpenseCategory.transport: return Icons.flight_rounded;
      case ExpenseCategory.shopping: return Icons.shopping_bag_rounded;
      case ExpenseCategory.health: return Icons.medical_services_rounded;
      case ExpenseCategory.entertainment: return Icons.movie_rounded;
      case ExpenseCategory.education: return Icons.menu_book_rounded;
      case ExpenseCategory.electricity: return Icons.bolt_rounded;
      case ExpenseCategory.home: return Icons.home_rounded;
      case ExpenseCategory.insurance: return Icons.shield_rounded;
      case ExpenseCategory.marketing: return Icons.campaign_rounded;
      case ExpenseCategory.internet: return Icons.wifi_rounded;
      case ExpenseCategory.water: return Icons.water_drop_rounded;
      case ExpenseCategory.rent: return Icons.key_rounded;
      case ExpenseCategory.gym: return Icons.fitness_center_rounded;
      case ExpenseCategory.subscription: return Icons.notifications_active_rounded;
      case ExpenseCategory.vacation: return Icons.park_rounded;
      case ExpenseCategory.hotels: return Icons.hotel_rounded;
      case ExpenseCategory.other: return Icons.grid_view_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food: return const Color(0xFF34D399); // Green
      case ExpenseCategory.transport: return const Color(0xFF38BDF8); // Light Blue
      case ExpenseCategory.shopping: return const Color(0xFF34D399); // Green
      case ExpenseCategory.health: return const Color(0xFFFF8B94); // Pinkish red
      case ExpenseCategory.entertainment: return const Color(0xFFA78BFA); // Purple
      case ExpenseCategory.education: return const Color(0xFF818CF8); // Indigo
      case ExpenseCategory.electricity: return const Color(0xFFFBBF24); // Yellow
      case ExpenseCategory.home: return const Color(0xFFC084FC); // Purple
      case ExpenseCategory.insurance: return const Color(0xFF2DD4BF); // Teal
      case ExpenseCategory.marketing: return const Color(0xFFFBBF24); // Yellow
      case ExpenseCategory.internet: return const Color(0xFF818CF8); // Indigo
      case ExpenseCategory.water: return const Color(0xFF38BDF8); // Light Blue
      case ExpenseCategory.rent: return const Color(0xFFFB923C); // Orange
      case ExpenseCategory.gym: return const Color(0xFFFB923C); // Orange
      case ExpenseCategory.subscription: return const Color(0xFFC084FC); // Purple
      case ExpenseCategory.vacation: return const Color(0xFF34D399); // Green
      case ExpenseCategory.hotels: return const Color(0xFFF43F5E); // Rose
      case ExpenseCategory.other: return const Color(0xFF9CA3AF); // Gray
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
