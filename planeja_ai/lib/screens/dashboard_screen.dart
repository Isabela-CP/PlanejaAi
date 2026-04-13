import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final summaryData = {
    'totalIncome': 5420.00,
    'totalExpenses': 3240.50,
    'balance': 2179.50,
    'savings': 1800.00,
  };

  final categoryData = [
    {'name': 'Alimentação', 'value': 850.0, 'color': const Color(0xFFFF6B6B)},
    {'name': 'Transporte', 'value': 420.0, 'color': const Color(0xFF4ECDC4)},
    {'name': 'Entretenimento', 'value': 320.0, 'color': const Color(0xFF45B7D1)},
    {'name': 'Contas', 'value': 950.0, 'color': const Color(0xFF96CEB4)},
    {'name': 'Compras', 'value': 680.0, 'color': const Color(0xFFFECA57)},
  ];

  final formatCurrency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Painel',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ).animate().fade().slideX(),
              ],
            ),
            const SizedBox(height: 24),

            // Summary Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: constraints.maxWidth > 500 ? 1.5 : 2.5,
                  children: [
                    _buildSummaryCard(
                      'Receita Total',
                      summaryData['totalIncome']!,
                      LucideIcons.trendingUp,
                      const Color(0xFF10B981), // success (green)
                      '+12% do mês passado',
                    ).animate().fade(delay: 100.ms).slideY(),
                    _buildSummaryCard(
                      'Gastos Totais',
                      summaryData['totalExpenses']!,
                      LucideIcons.trendingDown,
                      const Color(0xFFEF4444), // destructive (red)
                      '+5% do mês passado',
                    ).animate().fade(delay: 200.ms).slideY(),
                    _buildSummaryCard(
                      'Saldo',
                      summaryData['balance']!,
                      LucideIcons.dollarSign,
                      const Color(0xFF3B82F6), // primary
                      '+18% do mês passado',
                    ).animate().fade(delay: 300.ms).slideY(),
                    _buildSummaryCard(
                      'Economia',
                      summaryData['savings']!,
                      LucideIcons.piggyBank,
                      const Color(0xFFA855F7), // secondary
                      '+8% do mês passado',
                    ).animate().fade(delay: 400.ms).slideY(),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Charts Layer
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildPieChartCard()),
                          const SizedBox(width: 24),
                          Expanded(child: _buildBarChartCard()),
                        ],
                      )
                    : Column(
                        children: [
                          _buildPieChartCard(),
                          const SizedBox(height: 24),
                          _buildBarChartCard(),
                        ],
                      );
              },
            ).animate().fade(delay: 500.ms),

            const SizedBox(height: 24),
            _buildLineChartCard().animate().fade(delay: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, IconData icon, Color iconColor, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Icon(icon, color: iconColor, size: 20),
              ],
            ),
            Text(
              formatCurrency.format(amount),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gastos por Categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: categoryData.map((data) {
                    final value = data['value'] as double;
                    final color = data['color'] as Color;
                    final title = data['name'] as String;
                    return PieChartSectionData(
                      color: color,
                      value: value,
                      title: '${(value / 3240.5 * 100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard() {
    final barGroups = [
      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 4800, color: const Color(0xFF10B981)), BarChartRodData(toY: 3200, color: const Color(0xFFEF4444))]),
      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5200, color: const Color(0xFF10B981)), BarChartRodData(toY: 3100, color: const Color(0xFFEF4444))]),
      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 5420, color: const Color(0xFF10B981)), BarChartRodData(toY: 3240, color: const Color(0xFFEF4444))]),
      BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 5100, color: const Color(0xFF10B981)), BarChartRodData(toY: 2950, color: const Color(0xFFEF4444))]),
      BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 5300, color: const Color(0xFF10B981)), BarChartRodData(toY: 3100, color: const Color(0xFFEF4444))]),
      BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 5420, color: const Color(0xFF10B981)), BarChartRodData(toY: 3240, color: const Color(0xFFEF4444))]),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Receita vs Gastos Mensais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'];
                          if (value.toInt() >= 0 && value.toInt() < titles.length) {
                            return Padding(padding: const EdgeInsets.only(top: 8), child: Text(titles[value.toInt()]));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartCard() {
    final spots = [
      const FlSpot(0, 1600),
      const FlSpot(1, 1700),
      const FlSpot(2, 1880),
      const FlSpot(3, 2030),
      const FlSpot(4, 2230),
      const FlSpot(5, 2179),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saldo ao Longo do Tempo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'];
                          if (value.toInt() >= 0 && value.toInt() < titles.length) {
                            return Padding(padding: const EdgeInsets.only(top: 8), child: Text(titles[value.toInt()]));
                          }
                          return const Text('');
                        },
                        interval: 1,
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFF6BB319),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF6BB319).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
