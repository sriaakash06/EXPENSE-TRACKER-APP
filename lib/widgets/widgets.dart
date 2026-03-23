import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class PieChartWidget extends StatefulWidget {
  final Map<ExpenseCategory, double> data;
  const PieChartWidget({super.key, required this.data});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Center(
        child: Text('No data yet', style: TextStyle(color: Theme.of(context).cardColor.withOpacity(0.54))),
      );
    }
    final total = widget.data.values.fold(0.0, (a, b) => a + b);
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: _buildSections(total),
              centerSpaceRadius: 50,
              sectionsSpace: 3,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: widget.data.entries.map((entry) {
            return _LegendItem(
              color: entry.key.color,
              label: entry.key.displayName,
              percent: total > 0 ? (entry.value / total * 100) : 0,
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(double total) {
    final entries = widget.data.entries.toList();
    return List.generate(entries.length, (i) {
      final isTouched = i == _touchedIndex;
      final entry = entries[i];
      final pct = total > 0 ? (entry.value / total * 100) : 0;
      return PieChartSectionData(
        color: entry.key.color,
        value: entry.value,
        title: '${pct.toStringAsFixed(0)}%',
        radius: isTouched ? 70 : 60,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 11,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).cardColor,
        ),
      );
    });
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double percent;
  const _LegendItem(
      {required this.color, required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label (${percent.toStringAsFixed(0)}%)',
          style: TextStyle(color: Theme.of(context).cardColor.withOpacity(0.7), fontSize: 11),
        ),
      ],
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final Map<String, double> weeklyData;
  const BarChartWidget({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxVal =
        weeklyData.values.isEmpty ? 1.0 : weeklyData.values.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxVal > 0 ? maxVal * 1.3 : 100,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF2D2D44),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '₹${rod.toY.toStringAsFixed(0)}',
                TextStyle(color: Theme.of(context).cardColor, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (val, meta) {
                if (val == 0) return const Text('');
                return Text(
                  '₹${val.toInt()}',
                  style: TextStyle(color: Theme.of(context).cardColor.withOpacity(0.54), fontSize: 9),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx < 0 || idx >= days.length) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    days[idx],
                    style:
                        TextStyle(color: Theme.of(context).cardColor.withOpacity(0.7), fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (val) => FlLine(
            color: Theme.of(context).cardColor.withOpacity(0.05),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(days.length, (i) {
          final val = weeklyData[days[i]] ?? 0.0;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: val,
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary, const Color(0xFFA78BFA)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 22,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class CategorySummaryList extends StatelessWidget {
  final Map<ExpenseCategory, double> data;
  const CategorySummaryList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.map((entry) {
        final pct = total > 0 ? entry.value / total : 0.0;
        return _CategoryRow(
          category: entry.key,
          amount: entry.value,
          percent: pct,
        );
      }).toList(),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final ExpenseCategory category;
  final double amount;
  final double percent;
  const _CategoryRow(
      {required this.category, required this.amount, required this.percent});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(category.icon, color: category.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.displayName,
                        style: TextStyle(
                            color: Theme.of(context).cardColor, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Theme.of(context).cardColor.withOpacity(0.08),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(category.color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                fmt.format(amount),
                style: TextStyle(
                    color: category.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).cardColor.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  color: Theme.of(context).cardColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  TextStyle(color: Theme.of(context).cardColor.withOpacity(0.54), fontSize: 12)),
        ],
      ),
    );
  }
}

class ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExpenseListTile({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFmt = DateFormat('d MMM, yyyy');

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.red),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).cardColor.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: expense.category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(expense.category.icon,
                    color: expense.category.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title,
                        style: TextStyle(
                            color: Theme.of(context).cardColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      '${expense.category.displayName} • ${dateFmt.format(expense.date)}',
                      style: TextStyle(
                          color: Theme.of(context).cardColor.withOpacity(0.54), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                fmt.format(expense.amount),
                style: TextStyle(
                  color: expense.category.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
