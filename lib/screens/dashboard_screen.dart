import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../widgets/widgets.dart';
import '../models/expense.dart';
import 'add_edit_expense_sheet.dart';

class DashboardScreen extends StatelessWidget {
  final ExpenseProvider provider;
  const DashboardScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final totalSpent = provider.totalSpent;
    final monthTotal = provider.thisMonthTotal;
    final catTotals = provider.categoryTotals;
    final weekly = provider.weeklyData;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // HEADER CARD — total balance style
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Spent',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 6),
                Text(fmt.format(totalSpent),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_rounded,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'This month: ${fmt.format(monthTotal)}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // STAT CHIPS
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Transactions',
                  value: '${provider.expenses.length}',
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF4ECDC4),
                  bgColor: const Color(0xFF1E1E2E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Categories',
                  value: '${catTotals.length}',
                  icon: Icons.category_rounded,
                  color: const Color(0xFFA78BFA),
                  bgColor: const Color(0xFF1E1E2E),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // PIE CHART
          _SectionHeader(title: 'By Category'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: catTotals.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Add expenses to see the chart',
                          style: TextStyle(color: Colors.white54)),
                    ),
                  )
                : PieChartWidget(data: catTotals),
          ),

          const SizedBox(height: 24),

          // BAR CHART
          _SectionHeader(title: 'This Week'),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: BarChartWidget(weeklyData: weekly),
          ),

          const SizedBox(height: 24),

          // CATEGORY BREAKDOWN
          _SectionHeader(title: 'Category Breakdown'),
          const SizedBox(height: 12),
          if (catTotals.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child:
                    Text('No data yet', style: TextStyle(color: Colors.white54)),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(24),
                border:
                    Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: CategorySummaryList(data: catTotals),
            ),

          const SizedBox(height: 24),

          // RECENT EXPENSES
          _SectionHeader(title: 'Recent Expenses'),
          const SizedBox(height: 12),
          if (provider.recentExpenses.isEmpty)
            _EmptyState()
          else
            Column(
              children: provider.recentExpenses.map((e) {
                return ExpenseListTile(
                  expense: e,
                  onEdit: () => _showEditSheet(context, e),
                  onDelete: () => _confirmDelete(context, e),
                );
              }).toList(),
            ),

          const SizedBox(height: 40),
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
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold));
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded,
              size: 48, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),
          const Text('No expenses yet',
              style: TextStyle(color: Colors.white54, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('Tap + to add your first expense',
              style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}
