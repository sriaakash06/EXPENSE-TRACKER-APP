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
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final totalSpent = provider.thisMonthTotal;
    final dateFmt = DateFormat('E, d MMM');
    final today = dateFmt.format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F9),
      body: Stack(
        children: [
          // Top Gradient Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE4C9FF), // Light purple
                    Color(0xFFF0E0FF), // Lighter purple
                    Color(0xFFF6F6F9), // Background color fade
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.0, 0.5, 1.0],
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
                      _buildHeaderIcon(Icons.settings_outlined),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF1B1B2F)),
                          const SizedBox(width: 8),
                          Text(
                            today,
                            style: const TextStyle(
                              color: Color(0xFF1B1B2F),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      _buildHeaderIcon(Icons.notifications_none_rounded),
                    ],
                  ),
                  
                  const SizedBox(height: 35),
                  
                  // This Month Spend
                  const Text(
                    'This Month Spend',
                    style: TextStyle(
                      color: Color(0xFF7A7A90),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fmt.format(totalSpent),
                    style: const TextStyle(
                      color: Color(0xFF1B1B2F),
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_right_alt_rounded, size: 16, color: Color(0xFF1B1B2F)),
                      const SizedBox(width: 4),
                      const Text(
                        '67% below last month',
                        style: TextStyle(
                          color: Color(0xFF1B1B2F),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF1B1B2F), size: 22),
                            const SizedBox(width: 12),
                            const Text(
                              'Spending Wallet',
                              style: TextStyle(
                                color: Color(0xFF1B1B2F),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              '\$5,631.22',
                              style: TextStyle(
                                color: Color(0xFF7A7A90),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFF7A7A90), size: 20),
                          ],
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 35),
                  
                  // Recent Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          color: Color(0xFF1B1B2F),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          color: const Color(0xFF7A7A90),
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
                      child: const Text('No transactions yet', style: TextStyle(color: Color(0xFF7A7A90))),
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

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Icon(icon, color: const Color(0xFF1B1B2F), size: 20),
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
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFmt = DateFormat('d MMM yyyy');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
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
                    style: const TextStyle(
                      color: Color(0xFF1B1B2F),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFmt.format(expense.date),
                    style: const TextStyle(
                      color: Color(0xFF7A7A90),
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
