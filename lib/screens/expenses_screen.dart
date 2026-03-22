import 'package:flutter/material.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../widgets/widgets.dart';
import 'add_edit_expense_sheet.dart';

class ExpensesScreen extends StatelessWidget {
  final ExpenseProvider provider;
  const ExpensesScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final filtered = provider.filteredExpenses;
    final categories = ['All', ...ExpenseCategory.values.map((e) => e.displayName)];

    return Column(
      children: [
        // Filter chips
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final cat = categories[i];
              final isSelected = provider.selectedFilter == cat;
              return GestureDetector(
                onTap: () => provider.setFilter(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF7C3AED)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded,
                          size: 64, color: Colors.white.withOpacity(0.15)),
                      const SizedBox(height: 16),
                      const Text('No expenses found',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final e = filtered[i];
                    return ExpenseListTile(
                      expense: e,
                      onEdit: () => _showEditSheet(context, e),
                      onDelete: () => _confirmDelete(context, e),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showEditSheet(BuildContext context, Expense e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditExpenseSheet(provider: provider, expense: e),
    );
  }

  void _confirmDelete(BuildContext context, Expense e) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Expense',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${e.title}"? This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteExpense(e.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
