import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../services/export_service.dart';
import '../models/expense.dart';

class AnalyticsScreen extends StatefulWidget {
  final ExpenseProvider provider;
  const AnalyticsScreen({super.key, required this.provider});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // Get human readable month-year name
  String _displayName(String key) {
    try {
      DateTime d = DateFormat('MM-yyyy').parse(key);
      return DateFormat('MMMM yyyy').format(d);
    } catch (_) {
      return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final provider = widget.provider;
    final _selectedMonthYear = provider.globalSelectedMonthYear;

    // Filter current selection
    List<int> dateParts = _selectedMonthYear.split('-').map(int.parse).toList();
    final currentSelectionExpenses = provider.getExpensesByMonth(dateParts[0], dateParts[1]);
    
    double totalSpentThisMonth = currentSelectionExpenses.fold(0.0, (sum, e) => sum + e.amount);
    double initialBudget = provider.initialWalletBalance;
    double remaining = initialBudget - totalSpentThisMonth;

    // Charts use the last 6 months overall data
    Map<String, double> monthData = provider.monthlyData;
    final sortedKeys = monthData.keys.toList()
      ..sort((a, b) {
        DateTime da = DateFormat('MM-yyyy').parse(a);
        DateTime db = DateFormat('MM-yyyy').parse(b);
        return da.compareTo(db);
      });

    // Find the max value to scale the chart
    double maxVal = 0;
    for (var val in monthData.values) {
      if (val > maxVal) maxVal = val;
    }
    if (initialBudget > maxVal) maxVal = initialBudget;
    if (maxVal == 0) maxVal = 100;
    maxVal = maxVal * 1.3;

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
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                    Theme.of(context).scaffoldBackgroundColor,
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
                  
                  // Export Buttons - passed the filtered expenses
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildExportButton(
                        context, 
                        'PDF', 
                        Icons.picture_as_pdf_rounded, 
                        const Color(0xFFFF6B6B),
                        () => ExportService.exportToPdf(
                          currentSelectionExpenses, 
                          title: 'Expense Report ${_displayName(_selectedMonthYear)}',
                          budget: initialBudget,
                          remaining: remaining,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildExportButton(
                        context, 
                        'Excel', 
                        Icons.table_view_rounded, 
                        const Color(0xFF34D399),
                        () => ExportService.exportToExcel(
                          currentSelectionExpenses, 
                          title: 'Expenses Export ${_displayName(_selectedMonthYear)}',
                          budget: initialBudget,
                          remaining: remaining,
                        ),
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
                        // Header: Selectable Month
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PopupMenuButton<String>(
                              onSelected: (val) => provider.setGlobalMonthYear(val),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              itemBuilder: (context) => sortedKeys.map((k) => PopupMenuItem(
                                value: k,
                                child: Text(_displayName(k), style: const TextStyle(fontSize: 13)),
                              )).toList(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(color: Theme.of(context).dividerColor),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _displayName(_selectedMonthYear),
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.keyboard_arrow_down_rounded,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        size: 16),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                _buildLegendItem(context, const Color(0xFF818CF8), 'Budget'),
                                const SizedBox(width: 8),
                                _buildLegendItem(context, const Color(0xFF34D399), 'Expense'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Real logic Grouped Bar Chart
                        if (monthData.values.every((v) => v == 0) && provider.expenses.isEmpty)
                          SizedBox(
                            height: 180,
                            child: Center(
                              child: Text('No real data yet to show trends.',
                                  style: TextStyle(color: Theme.of(context).disabledColor)),
                            ),
                          )
                        else
                          SizedBox(
                            height: 180,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxVal,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipColor: (group) => Theme.of(context).cardColor,
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      String label = rodIndex == 0 ? "Budget" : "Spent";
                                      return BarTooltipItem(
                                        '$label\n',
                                        TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                                        children: [
                                          TextSpan(
                                            text: fmt.format(rod.toY),
                                            style: TextStyle(color: rod.color, fontSize: 13),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        int index = value.toInt();
                                        if (index < 0 || index >= sortedKeys.length) return const SizedBox.shrink();
                                        String key = sortedKeys[index];
                                        DateTime d = DateFormat('MM-yyyy').parse(key);
                                        String label = DateFormat('MMM').format(d);
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            label,
                                            style: TextStyle(
                                              color: key == _selectedMonthYear 
                                                  ? Theme.of(context).colorScheme.primary 
                                                  : Theme.of(context).colorScheme.onSurfaceVariant, 
                                              fontWeight: FontWeight.bold, 
                                              fontSize: 11
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 32,
                                      getTitlesWidget: (value, meta) {
                                        if (value == 0) return const SizedBox.shrink();
                                        return Text(
                                          '₹${(value / 1000).toStringAsFixed(1)}k',
                                          style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 10, fontWeight: FontWeight.w500),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(sortedKeys.length, (i) {
                                  double expenseValue = monthData[sortedKeys[i]] ?? 0.0;
                                  bool isSelected = sortedKeys[i] == _selectedMonthYear;
                                  return _buildBarGroup(context, i, initialBudget, expenseValue, isSelected);
                                }),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Summary Cards - updated with current selection
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context: context,
                          title: 'Monthly Budget',
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
                          title: 'Monthly Spent',
                          amount: fmt.format(totalSpentThisMonth),
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
                    icon: remaining >= 0 ? Icons.savings_rounded : Icons.warning_amber_rounded,
                    color: remaining >= 0 ? const Color(0xFF34D399) : const Color(0xFFFF6B6B),
                    bgColor: remaining >= 0 ? const Color(0xFF34D399).withOpacity(0.1) : const Color(0xFFFF6B6B).withOpacity(0.1),
                  ),

                  const SizedBox(height: 35),

                  _sectionHeader(context, 'Monthly History'),
                  const SizedBox(height: 16),

                  // History for selected month
                  if (currentSelectionExpenses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today_outlined, color: Theme.of(context).disabledColor, size: 40),
                          const SizedBox(height: 12),
                          Text('No transactions for this month.',
                              style: TextStyle(color: Theme.of(context).disabledColor)),
                        ],
                      ),
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
                        ]
                      ),
                      child: Column(
                        children: _buildFilteredHistory(context, currentSelectionExpenses),
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

  Widget _sectionHeader(BuildContext context, String title) {
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

  List<Widget> _buildFilteredHistory(BuildContext context, List<Expense> expenses) {
    expenses.sort((a, b) => b.date.compareTo(a.date));
    final Map<String, List<double>> grouped = {};
    for (var e in expenses) {
      String dateStr = DateFormat('d MMMM yyyy').format(e.date);
      if (!grouped.containsKey(dateStr)) grouped[dateStr] = [];
      grouped[dateStr]!.add(e.amount);
    }

    List<Widget> rows = [];
    int index = 0;
    grouped.forEach((date, amounts) {
      rows.add(_buildHistoryRow(context, date, amounts));
      if (index < grouped.length - 1) {
        rows.add(Divider(height: 1, color: Theme.of(context).dividerColor, indent: 20, endIndent: 20));
      }
      index++;
    });
    return rows;
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // GROUPED BAR GROUP [Budget, Spent]
  BarChartGroupData _buildBarGroup(BuildContext context, int x, double budget, double expenseVal, bool isSelected) {
    return BarChartGroupData(
      x: x,
      barRods: [
        // Budget Rod (Purple)
        BarChartRodData(
          toY: budget,
          color: const Color(0xFF818CF8).withOpacity(isSelected ? 1.0 : 0.6),
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        // Spent Rod (Green)
        BarChartRodData(
          toY: expenseVal,
          color: const Color(0xFF34D399).withOpacity(isSelected ? 1.0 : 0.6),
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
      barsSpace: 4,
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
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(amount, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHistoryRow(BuildContext context, String date, List<double> amounts) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date', style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(date, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: amounts.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('-₹${a.toInt()}', style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13, fontWeight: FontWeight.bold)),
            )).toList(),
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
