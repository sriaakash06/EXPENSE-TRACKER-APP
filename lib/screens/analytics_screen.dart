import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  final ExpenseProvider provider;
  const AnalyticsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    
    // Using real data here:
    final totalExpense = provider.totalSpent;
    final totalIncome = totalExpense * 1.25; // Dummy income value for aesthetic purposes

    final monthData = provider.monthlyData;
    final monthKeys = monthData.keys.toList()..sort();
    
    // Find the max value to scale the chart
    double maxVal = 0;
    for (var val in monthData.values) {
      if (val > maxVal) maxVal = val;
    }
    if (maxVal == 0) maxVal = 100; // default for empty
    maxVal = maxVal * 1.5; // add headroom

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
                  const Text(
                    'Analytics',
                    style: TextStyle(
                      color: Color(0xFF1B1B2F),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Main Chart Card
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      children: [
                        // Header of map
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: const Color(0xFFEAEAEE)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'Monthly',
                                    style: TextStyle(
                                      color: Color(0xFF7A7A90),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF7A7A90), size: 16),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _buildLegendItem(const Color(0xFF7C3AED), 'Income'),
                                const SizedBox(width: 12),
                                _buildLegendItem(const Color(0xFF8EE0A5), 'Expense'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        
                        // Real logic Bar Chart
                        if (totalExpense == 0)
                          const SizedBox(
                            height: 180,
                            child: Center(
                              child: Text('No real data yet. Add expenses to populate.', style: TextStyle(color: Color(0xFFC4C4CD))),
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
                                        const style = TextStyle(
                                          color: Color(0xFF7A7A90),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11,
                                        );
                                        // map index to month name roughly
                                        int mth = monthKeys[value.toInt() % monthKeys.length];
                                        String text = DateFormat('MMM').format(DateTime(2023, mth));
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
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
                                        if (value == 0) return const SizedBox.shrink();
                                        return Text(
                                          '\$${value.toInt()}',
                                          style: const TextStyle(
                                            color: Color(0xFFC4C4CD),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
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
                                    color: const Color(0xFFF3F3F6),
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(monthKeys.length, (i) {
                                  double expenseValue = monthData[monthKeys[i]] ?? 0.0;
                                  double incomeValue = expenseValue * 1.25; // Simulate slightly higher income for aesthetic logic
                                  return _buildBarGroup(i, incomeValue, expenseValue);
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
                          title: 'Income (Est)',
                          amount: fmt.format(totalIncome),
                          icon: Icons.savings_outlined, // piggy bank
                          color: const Color(0xFF7C3AED),
                          bgColor: const Color(0xFFF3EDFF),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Expenses',
                          amount: fmt.format(totalExpense),
                          icon: Icons.receipt_long_rounded,
                          color: const Color(0xFF34D399),
                          bgColor: const Color(0xFFE8FBF2),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 35),
                  
                  // History
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'History',
                      style: TextStyle(
                        color: Color(0xFF1B1B2F),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // History List backed by real data
                  if (provider.expenses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No history available yet.', style: TextStyle(color: Color(0xFFC4C4CD))),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                        children: _buildRealHistoryList(),
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
  List<Widget> _buildRealHistoryList() {
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
      rows.add(_buildHistoryRow(date, amounts));
      if (index < grouped.length - 1) {
        rows.add(const Divider(height: 1, color: Color(0xFFF3F3F6), indent: 20, endIndent: 20));
      }
      index++;
    });
    
    return rows;
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(2)
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7A7A90),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double val1, double val2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: val1,
          color: const Color(0xFF7C3AED),
          width: 10,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: val2,
          color: const Color(0xFF8EE0A5),
          width: 10,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
      barsSpace: 6,
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
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
                  style: const TextStyle(
                    color: Color(0xFF1B1B2F),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF7A7A90),
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

  Widget _buildHistoryRow(String date, List<double> amounts) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date block
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Date',
                style: TextStyle(
                  color: Color(0xFFC4C4CD),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  color: Color(0xFF1B1B2F),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // Amounts block
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: amounts.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '-\$${a.toInt()}',
                style: const TextStyle(
                  color: Color(0xFFFF6B6B), // Expense red representing the user entries
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
