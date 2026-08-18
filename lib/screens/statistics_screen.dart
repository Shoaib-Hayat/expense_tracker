import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Consumer<TransactionProvider>(
        builder: (
            context,
            provider,
            child,
            ) {
          return SingleChildScrollView(
            padding:
            const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                // =================================================
                // BALANCE
                // =================================================

                DashboardCard(
                  title: 'Current Balance',
                  value: provider.balance,
                  icon: Icons.account_balance_wallet,
                ),

                const SizedBox(height: 12),

                // =================================================
                // INCOME + EXPENSE
                // =================================================

                Row(
                  children: [

                    Expanded(
                      child: DashboardCard(
                        title: 'Income',
                        value:
                        provider.totalIncome,
                        icon:
                        Icons.trending_up,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: DashboardCard(
                        title: 'Expense',
                        value:
                        provider.totalExpense,
                        icon:
                        Icons.trending_down,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // =================================================
                // CHART TITLE
                // =================================================

                const Text(
                  'Last 6 Months',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Income vs Expense',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // BAR CHART
                // =================================================

                SizedBox(
                  height: 320,
                  child: BarChart(
                    BarChartData(
                      alignment:
                      BarChartAlignment.spaceAround,

                      maxY: _getMaxY(provider),

                      minY: 0,

                      gridData:
                      const FlGridData(
                        show: true,
                      ),

                      borderData:
                      FlBorderData(
                        show: false,
                      ),

                      titlesData:
                      FlTitlesData(
                        topTitles:
                        const AxisTitles(
                          sideTitles:
                          SideTitles(
                            showTitles: false,
                          ),
                        ),

                        rightTitles:
                        const AxisTitles(
                          sideTitles:
                          SideTitles(
                            showTitles: false,
                          ),
                        ),

                        leftTitles:
                        AxisTitles(
                          sideTitles:
                          SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                          ),
                        ),

                        bottomTitles:
                        AxisTitles(
                          sideTitles:
                          SideTitles(
                            showTitles: true,
                            reservedSize: 40,

                            getTitlesWidget:
                                (value, meta) {
                              final months =
                                  provider
                                      .lastSixMonths;

                              final index =
                              value.toInt();

                              if (index < 0 ||
                                  index >=
                                      months.length) {
                                return const SizedBox();
                              }

                              return Padding(
                                padding:
                                const EdgeInsets
                                    .only(
                                  top: 8,
                                ),
                                child: Text(
                                  DateFormat(
                                    'MMM',
                                  ).format(
                                    months[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      barGroups:
                      _buildBarGroups(
                        provider,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // LEGEND
                // =================================================

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    LegendItem(
                      icon: Icons.circle,
                      label: 'Income',
                    ),

                    const SizedBox(width: 25),

                    LegendItem(
                      icon: Icons.circle,
                      label: 'Expense',
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // =================================================
                // MONTH DETAILS
                // =================================================

                const Text(
                  'Monthly Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ...provider.lastSixMonths
                    .reversed
                    .map(
                      (month) {
                    final income =
                    provider.monthlyIncome(
                      month.year,
                      month.month,
                    );

                    final expense =
                    provider.monthlyExpense(
                      month.year,
                      month.month,
                    );

                    return Card(
                      margin:
                      const EdgeInsets.only(
                        bottom: 10,
                      ),

                      child: ListTile(
                        leading:
                        const CircleAvatar(
                          child: Icon(
                            Icons
                                .calendar_month,
                          ),
                        ),

                        title: Text(
                          DateFormat(
                            'MMMM yyyy',
                          ).format(month),

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          'Income: Rs. '
                              '${income.toStringAsFixed(0)}\n'
                              'Expense: Rs. '
                              '${expense.toStringAsFixed(0)}',
                        ),

                        isThreeLine: true,

                        trailing: Text(
                          'Rs. '
                              '${(income - expense).toStringAsFixed(0)}',

                          style:
                          TextStyle(
                            fontWeight:
                            FontWeight.bold,

                            color:
                            income - expense >=
                                0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // BAR GROUPS
  // =========================================================

  List<BarChartGroupData> _buildBarGroups(
      TransactionProvider provider,
      ) {
    return List.generate(
      provider.lastSixMonths.length,
          (index) {
        final month =
        provider.lastSixMonths[index];

        final income =
        provider.monthlyIncome(
          month.year,
          month.month,
        );

        final expense =
        provider.monthlyExpense(
          month.year,
          month.month,
        );

        return BarChartGroupData(
          x: index,

          barsSpace: 4,

          barRods: [
            BarChartRodData(
              toY: income,
              width: 10,
              borderRadius:
              BorderRadius.circular(4),
            ),

            BarChartRodData(
              toY: expense,
              width: 10,
              borderRadius:
              BorderRadius.circular(4),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // MAX Y
  // =========================================================

  double _getMaxY(
      TransactionProvider provider,
      ) {
    double maxValue = 1000;

    for (final month
    in provider.lastSixMonths) {
      final income =
      provider.monthlyIncome(
        month.year,
        month.month,
      );

      final expense =
      provider.monthlyExpense(
        month.year,
        month.month,
      );

      if (income > maxValue) {
        maxValue = income;
      }

      if (expense > maxValue) {
        maxValue = expense;
      }
    }

    return maxValue * 1.2;
  }
}

// =============================================================
// DASHBOARD CARD
// =============================================================

class DashboardCard
    extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Icon(
              icon,
              size: 28,
            ),

            const SizedBox(height: 10),

            Text(
              title,

              style:
              const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Rs. ${value.toStringAsFixed(0)}',

              style:
              const TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// LEGEND
// =============================================================

class LegendItem
    extends StatelessWidget {
  final IconData icon;
  final String label;

  const LegendItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
        ),

        const SizedBox(width: 6),

        Text(label),
      ],
    );
  }
}