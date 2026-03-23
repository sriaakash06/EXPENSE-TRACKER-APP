import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../services/export_service.dart';

class AnalyticsScreen extends StatelessWidget {
  final ExpenseProvider provider;
  const AnalyticsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    // Using real data here:
    double totalExpense = provider.totalSpent;
    double initialBudget = provider.initialWalletBalance;
    double remaining = provider.currentWalletBalance;

    Map<int, double> monthData = provider.monthlyData;

    final monthKeys = monthData.keys.toList()..sort();

    // Find the max value to scale the chart
    double maxVal = 0;
    for (var val in monthData.values) {
      if (val > maxVal) maxVal = val;
    }
    // Ensure budget line is visible on chart
    if (initialBudget > maxVal) maxVal = initialBudget;
    if (maxVal == 0) maxVal = 100; // default for empty
    maxVal = maxVal * 1.3; // add headroom

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
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer, // Light purple
                    Theme.of(context)
                        .colorScheme
                        .secondaryContainer, // Lighter purple
                    Theme.of(context)
                        .scaffoldBackgroundColor, // Background color fade
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
                  Text(
                    'Analytics',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Export Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildExportButton(
                        context, 
                        'PDF', 
                        Icons.picture_as_pdf_rounded, 
                        const Color(0xFFFF6B6B),
                        () => ExportService.exportToPdf(provider.expenses),
                      ),
                      const SizedBox(width: 12),
                      _buildExportButton(
                        context, 
                        'Excel', 
                        Icons.table_view_rounded, 
                        const Color(0xFF34D399),
                        () => ExportService.exportToExcel(provider.expenses),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Main Chart Card
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
                        // Header of map
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                    color: Theme.of(context).dividerColor),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Monthly',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      size: 16),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _buildLegendItem(
                                    context,
                                    Theme.of(context).colorScheme.secondary,
                                    'Expense'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Real logic Bar Chart
                        if (totalExpense == 0)
                          SizedBox(
                            height: 180,
                            child: Center(
                              child: Text(
                                  'No real data yet. Add expenses to populate.',
                                  style: TextStyle(
                                      color: Theme.of(context).disabledColor)),
                            ),
                          )
                        else
                          SizedBox(
                            height: 180,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxVal,
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final style = TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11,
                                        );
                                        int index = value.toInt();
                                        if (index < 0 ||
                                            index >= monthKeys.length)
                                          return const SizedBox.shrink();
                                        int mth = monthKeys[index];
                                        String text = DateFormat('MMM')
                                            .format(DateTime(2023, mth));
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(text, style: style),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 32,
                                      getTitlesWidget: (value, meta) {
                                        if (value == 0)
                                          return const SizedBox.shrink();
                                        return Text(
                                          '₹${value.toInt()}',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).disabledColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: maxVal / 2,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Theme.of(context).dividerColor,
                                    strokeWidth: 1,
                                  ),
                                ),
                                extraLinesData: initialBudget > 0
                                    ? ExtraLinesData(horizontalLines: [
                                        HorizontalLine(
                                          y: initialBudget,
                                          color: const Color(0xFF7C3AED)
                                              .withOpacity(0.7),
                                          strokeWidth: 1.5,
                                          dashArray: [6, 4],
                                          label: HorizontalLineLabel(
                                            show: true,
                                            alignment: Alignment.topRight,
                                            labelResolver: (line) =>
                                                'Budget ${fmt.format(initialBudget)}',
                                            style: const TextStyle(
                                              color: Color(0xFF7C3AED),
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ])
                                    : null,
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(monthKeys.length, (i) {
                                  double expenseValue =
                                      monthData[monthKeys[i]] ?? 0.0;
                                  return _buildBarGroup(
                                      context, i, expenseValue);
                                }),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context: context,
                          title: 'Initial Budget',
                          amount: fmt.format(initialBudget),
                          icon: Icons.account_balance_wallet_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          bgColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          context: context,
                          title: 'Total Spent',
                          amount: fmt.format(totalExpense),
                          icon: Icons.receipt_long_rounded,
                          color: const Color(0xFFFF6B6B),
                          bgColor: const Color(0xFFFF6B6B).withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCard(
                    context: context,
                    title: remaining >= 0 ? 'Remaining Balance' : 'Over Budget By',
                    amount: fmt.format(remaining.abs()),
                    icon: remaining >= 0
                        ? Icons.savings_rounded
                        : Icons.warning_amber_rounded,
                    color: remaining >= 0
                        ? const Color(0xFF34D399)
                        : const Color(0xFFFF6B6B),
                    bgColor: remaining >= 0
                        ? const Color(0xFF34D399).withOpacity(0.1)
                        : const Color(0xFFFF6B6B).withOpacity(0.1),
                  ),

                  const SizedBox(height: 35),

                  // History
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'History',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // History List backed by real data
                  if (provider.expenses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('No history available yet.',
                          style: TextStyle(
                              color: Theme.of(context).disabledColor)),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]),
                      child: Column(
                        children: _buildRealHistoryList(context),
                      ),
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

  // Generate the history list grouping transactions dynamically by their actual dates recorded
  List<Widget> _buildRealHistoryList(BuildContext context) {
    // Group real expenses by essentially their date formatted string
    final Map<String, List<double>> grouped = {};
    for (var e in provider.expenses) {
      String dateStr = DateFormat('d MMMM yyyy').format(e.date);
      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      grouped[dateStr]!.add(e.amount);
    }

    List<Widget> rows = [];
    int index = 0;
    grouped.forEach((date, amounts) {
      rows.add(_buildHistoryRow(context, date, amounts));
      if (index < grouped.length - 1) {
        rows.add(Divider(
            height: 1,
            color: Theme.of(context).dividerColor,
            indent: 20,
            endIndent: 20));
      }
      index++;
    });

    return rows;
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: color,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(
      BuildContext context, int x, double expenseVal) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: expenseVal,
          color: Theme.of(context).colorScheme.secondary,
          width: 10,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
      barsSpace: 6,
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHistoryRow(
      BuildContext context, String date, List<double> amounts) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date block
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date',
                style: TextStyle(
                  color: Theme.of(context).disabledColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // Amounts block
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: amounts
                .map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '-₹${a.toInt()}',
                        style: const TextStyle(
                          color: Color(
                              0xFFFF6B6B), // Expense red representing the user entries
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
  Widget _buildExportButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
