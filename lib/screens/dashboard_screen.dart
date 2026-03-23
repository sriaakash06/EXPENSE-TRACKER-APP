import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'add_edit_expense_sheet.dart';

class DashboardScreen extends StatelessWidget {
  final ExpenseProvider provider;
  const DashboardScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final totalSpent = provider.thisMonthTotal;
    // Set a base budget for realism. Updates dynamically as you spend.
    final walletBalance = provider.currentWalletBalance;
    final lastMonthSpent = provider.totalSpent - totalSpent; 
    final percentDiff = lastMonthSpent > 0 ? ((lastMonthSpent - totalSpent) / lastMonthSpent * 100).abs().toInt() : 0;
    final diffText = lastMonthSpent > totalSpent 
        ? '$percentDiff% below last month' 
        : (lastMonthSpent == 0 ? 'No prior month data' : '$percentDiff% above last month');
    final dateFmt = DateFormat('E, d MMM');
    final today = dateFmt.format(DateTime.now());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Top Gradient Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer, // Light purple
                    Theme.of(context).colorScheme.secondaryContainer, // Lighter purple
                    Theme.of(context).scaffoldBackgroundColor, // Background color fade
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
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
                  // App Bar Area
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => provider.toggleTheme(),
                        child: _buildHeaderIcon(
                          context,
                          provider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: 8),
                          Text(
                            today,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _showNotifications(context),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildHeaderIcon(context, Icons.notifications_none_rounded),
                            if (provider.currentWalletBalance < provider.initialWalletBalance * 0.2 &&
                                provider.initialWalletBalance > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF6B6B),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 35),
                  
                  // This Month Spend
                  Text(
                    'This Month Spend',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fmt.format(totalSpent),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_right_alt_rounded, size: 16, color: Theme.of(context).colorScheme.onSurface),
                      const SizedBox(width: 4),
                      Text(
                        diffText,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 45),
                  
                  // Spending Wallet Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    child: GestureDetector(
                      onTap: () => _showEditWalletBalance(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, color: Theme.of(context).colorScheme.onSurface, size: 22),
                              const SizedBox(width: 12),
                              Text(
                                'Wallet Balance',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                fmt.format(walletBalance),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.edit_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 16),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 35),
                  
                  // Recent Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Transactions List
                  if (provider.recentExpenses.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(30),
                      alignment: Alignment.center,
                      child: Text('No transactions yet', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    )
                  else
                    Column(
                      children: provider.recentExpenses.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ExpenseListTileLight(
                            expense: e,
                            onTap: () => _showEditSheet(context, e),
                          ),
                        );
                      }).toList(),
                    ),
                    
                  const SizedBox(height: 120), // Spacing for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(BuildContext context, IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 20),
    );
  }

  void _showNotifications(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final remaining = provider.currentWalletBalance;
    final budget = provider.initialWalletBalance;
    final spent = provider.totalSpent;

    final List<Map<String, dynamic>> notifications = [];

    if (budget > 0 && remaining < budget * 0.2 && remaining >= 0) {
      notifications.add({
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFFBBF24),
        'title': 'Low Balance Alert',
        'body': 'Only ${fmt.format(remaining)} left (${((remaining / budget) * 100).toStringAsFixed(0)}% remaining)',
      });
    }
    if (remaining < 0) {
      notifications.add({
        'icon': Icons.error_outline_rounded,
        'color': const Color(0xFFFF6B6B),
        'title': 'Over Budget!',
        'body': 'You have exceeded your budget by ${fmt.format(remaining.abs())}',
      });
    }
    if (provider.thisMonthTotal > 0) {
      notifications.add({
        'icon': Icons.bar_chart_rounded,
        'color': const Color(0xFF818CF8),
        'title': 'This Month',
        'body': 'You have spent ${fmt.format(provider.thisMonthTotal)} this month',
      });
    }
    if (spent > 0 && budget > 0) {
      notifications.add({
        'icon': Icons.lightbulb_outline_rounded,
        'color': const Color(0xFF34D399),
        'title': 'Spending Tip',
        'body': 'You have used ${((spent / budget) * 100).toStringAsFixed(0)}% of your initial budget',
      });
    }
    if (notifications.isEmpty) {
      notifications.add({
        'icon': Icons.check_circle_outline_rounded,
        'color': const Color(0xFF34D399),
        'title': 'All Good!',
        'body': 'You are on track with your budget. Keep it up!',
      });
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Notifications',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...notifications.map((n) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (n['color'] as Color).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n['title'] as String,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          n['body'] as String,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEditWalletBalance(BuildContext context) {
    final controller = TextEditingController(text: provider.initialWalletBalance.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Edit Wallet Balance', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Initial Balance (₹)',
            hintText: 'Enter new initial balance',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              final newBal = double.tryParse(controller.text.trim());
              if (newBal != null) {
                provider.setInitialWalletBalance(newBal);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
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
}

class ExpenseListTileLight extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  const ExpenseListTileLight({super.key, required this.expense, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFmt = DateFormat('d MMM yyyy');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: expense.category.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(expense.category.icon, color: expense.category.color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFmt.format(expense.date),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  '-${fmt.format(expense.amount)}',
                  style: const TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFD4D4E0), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
