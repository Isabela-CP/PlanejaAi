import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final formatCurrency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().fetchReportsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingReports) {
            return const Center(child: CircularProgressIndicator());
          }

          final summaryData = provider.reportSummary ??
              {
                'receita': provider.income,
                'despesa': provider.expenses,
                'liquido': provider.balance,
              };

          final totalIncome =
              (summaryData['receita'] as num?)?.toDouble() ?? 0.0;
          final totalExpenses =
              (summaryData['despesa'] as num?)?.toDouble() ?? 0.0;
          final balance = (summaryData['liquido'] as num?)?.toDouble() ?? 0.0;
          final savings = (summaryData['economia'] as num?)?.toDouble() ?? 0.0;

          final categoryBreakdown = provider.reportCategoryBreakdown ?? [];
          final evolucaoList = provider.reportBalanceEvolution ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                const Text(
                  'Painel',
                  style:
                      TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ).animate().fade().slideX(),
              ],
            ),
                const SizedBox(height: 24),

                // Summary Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 800
                        ? 4
                        : (constraints.maxWidth > 500 ? 2 : 1);
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
                          totalIncome,
                          LucideIcons.trendingUp,
                          const Color(0xFF10B981),
                          'Mês atual',
                        ).animate().fade(duration: 400.ms, delay: 50.ms).slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 400.ms,
                            curve: Curves.easeOut),
                        _buildSummaryCard(
                          'Gastos Totais',
                          totalExpenses,
                          LucideIcons.trendingDown,
                          const Color(0xFFEF4444),
                          'Mês atual',
                        )
                            .animate()
                            .fade(duration: 400.ms, delay: 100.ms)
                            .slideY(
                                begin: 0.1,
                                end: 0,
                                duration: 400.ms,
                                curve: Curves.easeOut),
                        _buildSummaryCard(
                          'Saldo',
                          balance,
                          LucideIcons.dollarSign,
                          const Color(0xFF3B82F6),
                          'Mês atual',
                        )
                            .animate()
                            .fade(duration: 400.ms, delay: 150.ms)
                            .slideY(
                                begin: 0.1,
                                end: 0,
                                duration: 400.ms,
                                curve: Curves.easeOut),
                        _buildSummaryCard(
                          'Economia',
                          savings,
                          LucideIcons.piggyBank,
                          const Color(0xFFA855F7),
                          'Mês atual',
                        )
                            .animate()
                            .fade(duration: 400.ms, delay: 200.ms)
                            .slideY(
                                begin: 0.1,
                                end: 0,
                                duration: 400.ms,
                                curve: Curves.easeOut),
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
                              Expanded(
                                  child: _buildPieChartCard(
                                      categoryBreakdown, totalExpenses)),
                              const SizedBox(width: 24),
                              Expanded(child: _buildBarChartCard(evolucaoList)),
                            ],
                          )
                        : Column(
                            children: [
                              _buildPieChartCard(
                                  categoryBreakdown, totalExpenses),
                              const SizedBox(height: 24),
                              _buildBarChartCard(evolucaoList),
                            ],
                          );
                  },
                ).animate().fade(duration: 400.ms, delay: 250.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOut),

                const SizedBox(height: 24),
                _buildLineChartCard(evolucaoList)
                    .animate()
                    .fade(duration: 400.ms, delay: 300.ms)
                    .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOut),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, IconData icon,
      Color iconColor, String subtitle) {
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
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
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
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard(
      List<dynamic> categoryBreakdown, double totalExpenses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gastos por Categoria',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: categoryBreakdown.isEmpty
                  ? const Center(child: Text('Sem gastos no período'))
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: categoryBreakdown.map((item) {
                          final value = (item['amount'] as num).toDouble();
                          String hexColor = item['colorHex'] as String;
                          if (!hexColor.startsWith('#')) hexColor = '#9E9E9E';
                          final color = Color(
                              int.parse(hexColor.replaceFirst('#', '0xFF')));

                          return PieChartSectionData(
                            color: color,
                            value: value,
                            title:
                                '${(item['percentage'] as num).toStringAsFixed(0)}%',
                            radius: 50,
                            titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
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

  Widget _buildBarChartCard(List<dynamic> evolucaoList) {
    double maxY = 0;
    for (var item in evolucaoList) {
      final r = (item['receitas'] as num).toDouble();
      final d = (item['despesas'] as num).toDouble();
      if (r > maxY) maxY = r;
      if (d > maxY) maxY = d;
    }
    maxY = maxY * 1.2;
    if (maxY > 0) {
      double interval = maxY > 1000 ? 500 : (maxY > 100 ? 100 : 50);
      maxY = (maxY / interval).ceil() * interval;
    }
    if (maxY == 0) maxY = 100;

    final barGroups = evolucaoList.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      return BarChartGroupData(
        x: idx,
        barRods: [
          BarChartRodData(
              toY: (item['receitas'] as num).toDouble(),
              color: const Color(0xFF10B981)),
          BarChartRodData(
              toY: (item['despesas'] as num).toDouble(),
              color: const Color(0xFFEF4444)),
        ],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Receita vs Gastos Mensais',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: evolucaoList.isEmpty
                  ? const Center(child: Text('Sem dados'))
                  : BarChart(
                      BarChartData(
                        maxY: maxY,
                        barGroups: barGroups,
                        borderData: FlBorderData(show: false),
                        gridData:
                            FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < evolucaoList.length) {
                                  final mesStr = evolucaoList[value.toInt()]
                                      ['mes'] as String;
                                  final parts = mesStr.split('-');
                                  final month = int.tryParse(parts[1]) ?? 1;
                                  final title = DateFormat('MMM', 'pt_BR')
                                      .format(DateTime(2000, month));
                                  return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(title,
                                          style:
                                              const TextStyle(fontSize: 12)));
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartCard(List<dynamic> evolucaoList) {
    double maxY = 0;
    double minY = 0;
    for (var item in evolucaoList) {
      final s = (item['saldo'] as num).toDouble();
      if (s > maxY) maxY = s;
      if (s < minY) minY = s;
    }
    maxY = maxY * 1.2;
    if (maxY > 0) {
      double interval = maxY > 1000 ? 500 : (maxY > 100 ? 100 : 50);
      maxY = (maxY / interval).ceil() * interval;
    }
    minY = minY < 0 ? minY * 1.2 : 0;
    if (maxY == 0) maxY = 100;

    final spots = evolucaoList.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      return FlSpot(idx.toDouble(), (item['saldo'] as num).toDouble());
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saldo ao Longo do Tempo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: evolucaoList.isEmpty
                  ? const Center(child: Text('Sem dados'))
                  : LineChart(
                      LineChartData(
                        maxY: maxY,
                        minY: minY,
                        gridData:
                            FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < evolucaoList.length) {
                                  final mesStr = evolucaoList[value.toInt()]
                                      ['mes'] as String;
                                  final parts = mesStr.split('-');
                                  final month = int.tryParse(parts[1]) ?? 1;
                                  final title = DateFormat('MMM', 'pt_BR')
                                      .format(DateTime(2000, month));
                                  return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(title,
                                          style:
                                              const TextStyle(fontSize: 12)));
                                }
                                return const Text('');
                              },
                              interval: 1,
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
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
