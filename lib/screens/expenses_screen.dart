import 'package:flutter/material.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'dashboard_screen.dart';
import 'add_edit_expense_sheet.dart';

class ExpensesScreen extends StatelessWidget {
  final ExpenseProvider provider;
  const ExpensesScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final filtered = provider.filteredExpenses;
    final categories = ['All', ...ExpenseCategory.values.map((e) => e.displayName)];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 16, bottom: 16),
            child: Text(
              'Transactions',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Filter chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Theme.of(context).cardColor : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
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
                          size: 64, color: Theme.of(context).disabledColor),
                      const SizedBox(height: 16),
                      Text('No expenses found',
                          style:
                              TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final e = filtered[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Dismissible(
                        key: ValueKey(e.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(Icons.delete_outline_rounded, color: Theme.of(context).cardColor),
                        ),
                        confirmDismiss: (direction) async {
                          _confirmDelete(context, e);
                          return false; // Dialog handles deletion
                        },
                        child: ExpenseListTileLight(
                          expense: e,
                          onTap: () => _showEditSheet(context, e),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
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
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete Expense',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        content: Text(
          'Delete "${e.title}"? This cannot be undone.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteExpense(e.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
