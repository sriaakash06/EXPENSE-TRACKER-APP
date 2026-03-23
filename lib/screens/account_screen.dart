import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'add_edit_expense_sheet.dart';
import '../widgets/expense_list_tile.dart';

class AccountScreen extends StatefulWidget {
  final ExpenseProvider provider;
  const AccountScreen({super.key, required this.provider});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _displayName(String key) {
    try {
      DateTime d = DateFormat('MM-yyyy').parse(key);
      return DateFormat('MMMM yyyy').format(d);
    } catch (_) {
      return key;
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will delete all expenses and reset your wallet budget. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.provider.resetAll();
      widget.provider.setGlobalMonthYear(DateFormat('MM-yyyy').format(DateTime.now()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared successfully.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final provider = widget.provider;
    final _selectedMonthYear = provider.globalSelectedMonthYear;

    // Filter current selection
    List<int> dateParts = _selectedMonthYear.split('-').map(int.parse).toList();
    final currentExpenses = provider.getExpensesByMonth(dateParts[0], dateParts[1]);

    final totalSpentThisMonth = currentExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final initialBudget = provider.initialWalletBalance;
    final remaining = initialBudget - totalSpentThisMonth;
    final txCount = currentExpenses.length;

    // Monthly data for the dropdown
    Map<String, double> monthData = provider.monthlyData;
    final sortedKeys = monthData.keys.toList()
      ..sort((a, b) {
        DateTime da = DateFormat('MM-yyyy').parse(a);
        DateTime db = DateFormat('MM-yyyy').parse(b);
        return da.compareTo(db);
      });

    // Category breakdown for pie based on CURRENT selection
    final Map<ExpenseCategory, double> catTotals = {};
    for (final e in currentExpenses) {
      catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
    }
    final pieData = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Gradient header bg
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.38,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48), // Spacer
                      Text(
                        'Account',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _clearAll,
                        icon: const Icon(Icons.refresh_rounded, color: Colors.redAccent, size: 22),
                        tooltip: 'Reset Tracker',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Avatar + name
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 12),
                  
                  // Month Dropdown
                  PopupMenuButton<String>(
                    onSelected: (val) => provider.setGlobalMonthYear(val),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    itemBuilder: (context) => sortedKeys.map((k) => PopupMenuItem(
                      value: k,
                      child: Text(_displayName(k), style: const TextStyle(fontSize: 13)),
                    )).toList(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _displayName(_selectedMonthYear),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    remaining >= 0
                        ? '${fmt.format(remaining)} remaining'
                        : 'Over budget by ${fmt.format(remaining.abs())}',
                    style: TextStyle(
                      color: remaining >= 0
                          ? const Color(0xFF34D399)
                          : const Color(0xFFFF6B6B),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Stats Row
                  Row(
                    children: [
                      _statTile(context, 'Set Budget', fmt.format(initialBudget),
                          Icons.account_balance_wallet_rounded,
                          Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      _statTile(context, 'Month Spent', fmt.format(totalSpentThisMonth),
                          Icons.receipt_long_rounded, const Color(0xFFFF6B6B)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _statTile(context, 'Status', remaining >= 0 ? 'Safe' : 'Critical',
                          remaining >= 0 ? Icons.check_circle_rounded : Icons.warning_rounded, 
                          remaining >= 0 ? const Color(0xFF34D399) : const Color(0xFFFF6B6B)),
                      const SizedBox(width: 12),
                      _statTile(context, 'Transactions', '$txCount',
                          Icons.swap_horiz_rounded, const Color(0xFF818CF8)),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Pie Chart Card
                  if (pieData.isNotEmpty) ...[
                    _sectionTitle(context, 'Category Stats'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: pieData.map((entry) {
                                  final pct = totalSpentThisMonth > 0
                                      ? (entry.value / totalSpentThisMonth * 100)
                                      : 0.0;
                                  return PieChartSectionData(
                                    value: entry.value,
                                    color: entry.key.color,
                                    title: '${pct.toStringAsFixed(0)}%',
                                    radius: 70,
                                    titleStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                                sectionsSpace: 3,
                                centerSpaceRadius: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Legend
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: pieData.map((entry) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: entry.key.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    entry.key.displayName,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    fmt.format(entry.value),
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.onSurface,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Transactions list for selected month
                  if (currentExpenses.isNotEmpty) ...[
                    _sectionTitle(context, 'Monthly History'),
                    const SizedBox(height: 16),
                    ...currentExpenses.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ExpenseListTileLight(
                            expense: e,
                            onTap: () => _showEditSheet(context, e),
                          ),
                        )),
                  ] else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 50,
                              color: Theme.of(context).disabledColor),
                          const SizedBox(height: 12),
                          Text(
                            'No data for ${_displayName(_selectedMonthYear)}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statTile(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, Expense e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditExpenseSheet(provider: widget.provider, expense: e),
    ).then((_) {
      // Reload on back to reflect changes
      setState(() {});
    });
  }
}
