import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/finance_provider.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'dart:io' as dart_io;
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _transactionType = 'all';
  final Set<String> _selectedCategories = {};
  bool _isGenerating = false;
  bool _hasReport = false;

  final _formatCurrency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _formatDate = DateFormat('dd/MM/yyyy');

  final _transactionTypes = [
    {'value': 'all', 'label': 'Todas as Transações'},
    {'value': 'income', 'label': 'Somente Receitas'},
    {'value': 'expense', 'label': 'Somente Despesas'},
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().fetchCategories(type: 'transaction');
    });
  }

  Color _parseColor(String? hex) {
    if (hex == null) return Colors.grey;
    final cleanHex = hex.replaceFirst('#', '');
    if (cleanHex.length == 6) {
      return Color(int.parse('FF$cleanHex', radix: 16));
    }
    return Colors.grey;
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'utensils': return LucideIcons.utensils;
      case 'car': return LucideIcons.car;
      case 'palmtree': return LucideIcons.palmtree;
      case 'home': return LucideIcons.home;
      case 'trending-up': return LucideIcons.trendingUp;
      case 'shopping-cart': return LucideIcons.shoppingCart;
      case 'bus': return LucideIcons.bus;
      case 'ticket': return LucideIcons.ticket;
      case 'sandwich': return LucideIcons.sandwich;
      case 'book-open': return LucideIcons.bookOpen;
      case 'help-circle': return LucideIcons.helpCircle;
      case 'heart': return LucideIcons.heart;
      case 'briefcase': return LucideIcons.briefcase;
      case 'music': return LucideIcons.music;
      case 'gamepad-2': return LucideIcons.gamepad2;
      case 'plane': return LucideIcons.plane;
      case 'dumbbell': return LucideIcons.dumbbell;
      case 'baby': return LucideIcons.baby;
      case 'shirt': return LucideIcons.shirt;
      case 'wifi': return LucideIcons.wifi;
      case 'zap': return LucideIcons.zap;
      case 'gift': return LucideIcons.gift;
      case 'coffee': return LucideIcons.coffee;
      case 'dollar-sign': return LucideIcons.dollarSign;
      case 'piggy-bank': return LucideIcons.piggyBank;
      case 'graduation-cap': return LucideIcons.graduationCap;
      case 'stethoscope': return LucideIcons.stethoscope;
      case 'paw-print': return LucideIcons.pawPrint;
      case 'film': return LucideIcons.film;
      default: return LucideIcons.helpCircle;
    }
  }

  String _formatMonthLabel(String monthStr) {
    try {
      final parts = monthStr.split('-');
      if (parts.length == 2) {
        final yearShort = parts[0].substring(2);
        final monthNum = int.parse(parts[1]);
        const monthNames = ['', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
        if (monthNum >= 1 && monthNum <= 12) {
          return "${monthNames[monthNum]}/$yearShort";
        }
      }
    } catch (_) {}
    return monthStr;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now.subtract(const Duration(days: 30)))
        : (_endDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _generateReport() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, selecione as datas de início e fim.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (!_startDate!.isBefore(_endDate!) && !_startDate!.isAtSameMomentAs(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('A data de início deve ser anterior ou igual à data de fim.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      await context.read<FinanceProvider>().fetchReportsData(
        startDate: _startDate,
        endDate: _endDate,
      );

      if (mounted) {
        setState(() {
          _hasReport = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relatório gerado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar relatório: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _exportReport(String format) async {
    if (!_hasReport) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gere um relatório antes de exportar.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (!['csv', 'pdf', 'excel'].contains(format)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Formato $format desconhecido!')),
      );
      return;
    }

    try {
      final financeProvider = context.read<FinanceProvider>();
      final summary = financeProvider.reportSummary ?? {};
      final rawBreakdown = financeProvider.reportCategoryBreakdown ?? [];
      
      final breakdown = rawBreakdown.where((item) {
        final catName = item['category'] as String? ?? '';
        if (_selectedCategories.isNotEmpty && !_selectedCategories.contains(catName)) {
          return false;
        }
        return true;
      }).toList();

      final evolution = financeProvider.reportBalanceEvolution ?? [];

      String? outputFile;
      
      if (format == 'csv') {
        final totalIncome = (summary['receita'] as num?)?.toDouble() ?? 0.0;
        final totalExpenses = (summary['despesa'] as num?)?.toDouble() ?? 0.0;
        final netIncome = (summary['liquido'] as num?)?.toDouble() ?? 0.0;

        StringBuffer csv = StringBuffer();
        csv.writeln('Relatorio Financeiro Planeja.Ai');
        csv.writeln('Data Inicial:;${_formatDate.format(_startDate!)}');
        csv.writeln('Data Final:;${_formatDate.format(_endDate!)}');
        csv.writeln('');
        csv.writeln('RESUMO');
        csv.writeln('Receita Total;Despesas Totais;Renda Liquida');
        csv.writeln('${totalIncome.toStringAsFixed(2)};${totalExpenses.toStringAsFixed(2)};${netIncome.toStringAsFixed(2)}');
        csv.writeln('');
        csv.writeln('DESPESAS POR CATEGORIA');
        csv.writeln('Categoria;Valor;Porcentagem');
        for (var item in breakdown) {
          final cat = item['category'] ?? 'Sem Categoria';
          final val = (item['amount'] as num?)?.toDouble() ?? 0.0;
          final pct = (item['percentage'] as num?)?.toDouble() ?? 0.0;
          csv.writeln('$cat;${val.toStringAsFixed(2)};${pct.toStringAsFixed(2)}%');
        }
        csv.writeln('');
        csv.writeln('EVOLUCAO DO SALDO');
        csv.writeln('Mes;Receitas;Despesas;Saldo;Acumulado');
        for (var item in evolution) {
          final mes = item['month'] ?? '';
          final rec = (item['income'] as num?)?.toDouble() ?? 0.0;
          final des = (item['expense'] as num?)?.toDouble() ?? 0.0;
          final sal = (item['net'] as num?)?.toDouble() ?? 0.0;
          final acu = (item['cumulative'] as num?)?.toDouble() ?? 0.0;
          csv.writeln('$mes;${rec.toStringAsFixed(2)};${des.toStringAsFixed(2)};${sal.toStringAsFixed(2)};${acu.toStringAsFixed(2)}');
        }

        outputFile = await file_picker.FilePicker.saveFile(
          dialogTitle: 'Onde deseja salvar o relatório?',
          fileName: 'relatorio_planeja_ai.csv',
          type: file_picker.FileType.custom,
          allowedExtensions: ['csv'],
        );

        if (outputFile != null) {
          final file = dart_io.File(outputFile);
          await file.writeAsString(csv.toString());
        }
      } else if (format == 'pdf') {
        outputFile = await file_picker.FilePicker.saveFile(
          dialogTitle: 'Onde deseja salvar o relatório PDF?',
          fileName: 'relatorio_planeja_ai.pdf',
          type: file_picker.FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (outputFile != null) {
          final bytes = await _generatePdfBytes(summary, breakdown, evolution);
          final file = dart_io.File(outputFile);
          await file.writeAsBytes(bytes);
        }
      } else if (format == 'excel') {
        outputFile = await file_picker.FilePicker.saveFile(
          dialogTitle: 'Onde deseja salvar o relatório Excel?',
          fileName: 'relatorio_planeja_ai.xlsx',
          type: file_picker.FileType.custom,
          allowedExtensions: ['xlsx'],
        );

        if (outputFile != null) {
          final bytes = await _generateExcelBytes(summary, breakdown, evolution);
          final file = dart_io.File(outputFile);
          await file.writeAsBytes(bytes);
        }
      }

      if (outputFile == null) return; // User canceled

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Relatório salvo com sucesso em $outputFile!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar arquivo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<Uint8List> _generatePdfBytes(Map summary, List rawBreakdown, List evolution) async {
    final pdf = pw.Document();
    
    final totalIncome = (summary['receita'] as num?)?.toDouble() ?? 0.0;
    final totalExpenses = (summary['despesa'] as num?)?.toDouble() ?? 0.0;
    final netIncome = (summary['liquido'] as num?)?.toDouble() ?? 0.0;

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          pw.Header(level: 0, child: pw.Text('Relatório Financeiro - Planeja.Ai', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.Text('Período: ${_formatDate.format(_startDate!)} a ${_formatDate.format(_endDate!)}'),
          pw.SizedBox(height: 20),
          pw.Text('Resumo', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Receita Total', 'Despesas Totais', 'Renda Líquida'],
              <String>[_formatCurrency.format(totalIncome), _formatCurrency.format(totalExpenses), _formatCurrency.format(netIncome)],
            ],
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFD4A017)),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            cellAlignment: pw.Alignment.centerLeft,
          ),
          pw.SizedBox(height: 30),
          pw.Text('Despesas por Categoria', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Categoria', 'Valor', 'Porcentagem'],
              ...rawBreakdown.map((item) => [
                item['category'] as String? ?? 'Sem Categoria',
                _formatCurrency.format((item['amount'] as num?)?.toDouble() ?? 0.0),
                '${((item['percentage'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1)}%'
              ])
            ],
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFD4A017)),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            cellAlignment: pw.Alignment.centerLeft,
          ),
          pw.SizedBox(height: 30),
          pw.Text('Evolução do Saldo', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Mês', 'Receitas', 'Despesas', 'Saldo', 'Acumulado'],
              ...evolution.map((item) => [
                item['month'] as String? ?? '',
                _formatCurrency.format((item['income'] as num?)?.toDouble() ?? 0.0),
                _formatCurrency.format((item['expense'] as num?)?.toDouble() ?? 0.0),
                _formatCurrency.format((item['net'] as num?)?.toDouble() ?? 0.0),
                _formatCurrency.format((item['cumulative'] as num?)?.toDouble() ?? 0.0),
              ])
            ],
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFD4A017)),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ];
      },
    ));
    return pdf.save();
  }

  Future<List<int>> _generateExcelBytes(Map summary, List rawBreakdown, List evolution) async {
    final excel = Excel.createExcel();
    final sheet = excel['Relatório'];
    excel.setDefaultSheet('Relatório');
    
    final totalIncome = (summary['receita'] as num?)?.toDouble() ?? 0.0;
    final totalExpenses = (summary['despesa'] as num?)?.toDouble() ?? 0.0;
    final netIncome = (summary['liquido'] as num?)?.toDouble() ?? 0.0;

    // Cabeçalho
    sheet.appendRow([TextCellValue('Relatório Financeiro Planeja.Ai')]);
    sheet.appendRow([TextCellValue('Data Inicial:'), TextCellValue(_formatDate.format(_startDate!))]);
    sheet.appendRow([TextCellValue('Data Final:'), TextCellValue(_formatDate.format(_endDate!))]);
    sheet.appendRow([TextCellValue('')]);

    // Resumo
    sheet.appendRow([TextCellValue('RESUMO')]);
    sheet.appendRow([TextCellValue('Receita Total'), TextCellValue('Despesas Totais'), TextCellValue('Renda Líquida')]);
    sheet.appendRow([
      TextCellValue(_formatCurrency.format(totalIncome)), 
      TextCellValue(_formatCurrency.format(totalExpenses)), 
      TextCellValue(_formatCurrency.format(netIncome))
    ]);
    sheet.appendRow([TextCellValue('')]);

    // Categorias
    sheet.appendRow([TextCellValue('DESPESAS POR CATEGORIA')]);
    sheet.appendRow([TextCellValue('Categoria'), TextCellValue('Valor'), TextCellValue('Porcentagem')]);
    for (var item in rawBreakdown) {
      final cat = item['category'] as String? ?? 'Sem Categoria';
      final val = (item['amount'] as num?)?.toDouble() ?? 0.0;
      final pct = (item['percentage'] as num?)?.toDouble() ?? 0.0;
      sheet.appendRow([
        TextCellValue(cat),
        TextCellValue(_formatCurrency.format(val)),
        TextCellValue('${pct.toStringAsFixed(1)}%')
      ]);
    }
    sheet.appendRow([TextCellValue('')]);

    // Evolução
    sheet.appendRow([TextCellValue('EVOLUÇÃO DO SALDO')]);
    sheet.appendRow([TextCellValue('Mês'), TextCellValue('Receitas'), TextCellValue('Despesas'), TextCellValue('Saldo'), TextCellValue('Acumulado')]);
    for (var item in evolution) {
      final mes = item['month'] as String? ?? '';
      final rec = (item['income'] as num?)?.toDouble() ?? 0.0;
      final des = (item['expense'] as num?)?.toDouble() ?? 0.0;
      final sal = (item['net'] as num?)?.toDouble() ?? 0.0;
      final acu = (item['cumulative'] as num?)?.toDouble() ?? 0.0;
      sheet.appendRow([
        TextCellValue(mes),
        TextCellValue(_formatCurrency.format(rec)),
        TextCellValue(_formatCurrency.format(des)),
        TextCellValue(_formatCurrency.format(sal)),
        TextCellValue(_formatCurrency.format(acu))
      ]);
    }

    return excel.encode()!;
  }

  Widget _buildFilterCard(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurface.withOpacity(0.6);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.filter, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Filtros do Relatório',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // Data início, Data fim, Tipo e Botão
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                SizedBox(
                  width: 200,
                  child: _buildDateField(
                    label: 'Data de Início',
                    value: _startDate,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: _buildDateField(
                    label: 'Data de Fim',
                    value: _endDate,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text('Tipo de Transação', style: theme.textTheme.titleSmall),
                      ),
                      DropdownButtonFormField<String>(
                        value: _transactionType,
                        items: _transactionTypes.map((t) => DropdownMenuItem(
                          value: t['value'],
                          child: Text(t['label']!),
                        )).toList(),
                        onChanged: (val) => setState(() => _transactionType = val!),
                        decoration: const InputDecoration(hintText: 'Selecione'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateReport,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.bar_chart, size: 18),
                    label: Text(_isGenerating ? 'Gerando...' : 'Gerar Relatório'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 16),

            // Categorias
            Text('Categorias (vazio = todas)',
                style: theme.textTheme.titleSmall?.copyWith(color: mutedColor)),
            const SizedBox(height: 12),
            Consumer<FinanceProvider>(
              builder: (context, financeProvider, child) {
                final categoriesList = financeProvider.transactionCategories.map((c) => c.name).toList();
                if (categoriesList.isEmpty) {
                  return Text(
                    'Nenhuma categoria encontrada.',
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categoriesList.map((cat) {
                    final isSelected = _selectedCategories.contains(cat);
                    return FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedCategories.add(cat);
                          } else {
                            _selectedCategories.remove(cat);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({required String label, required DateTime? value, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: theme.textTheme.titleSmall),
        ),
        InkWell(
          onTap: onTap,
          child: InputDecorator(
            decoration: const InputDecoration(),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 8),
                Text(
                  value == null ? 'Selecionar data' : _formatDate.format(value),
                  style: TextStyle(
                    color: value == null ? theme.colorScheme.onSurface.withOpacity(0.5) : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
        child: Center(
          child: Column(
            children: [
              Icon(LucideIcons.fileText, size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text('Pronto para Gerar seu Relatório',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                'Selecione o intervalo de datas e os filtros acima,\nem seguida clique em "Gerar Relatório".',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.97, 0.97));
  }

  Widget _buildLineChartCard(List<dynamic> evolution) {
    final theme = Theme.of(context);
    if (evolution.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = <FlSpot>[];
    double minY = 0.0;
    double maxY = 0.0;

    for (int i = 0; i < evolution.length; i++) {
      final val = (evolution[i]['cumulative'] as num?)?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), val));
      if (i == 0) {
        minY = val;
        maxY = val;
      } else {
        if (val < minY) minY = val;
        if (val > maxY) maxY = val;
      }
    }

    final range = maxY - minY;
    if (range == 0) {
      minY -= 100;
      maxY += 100;
    } else {
      minY -= range * 0.15;
      maxY += range * 0.15;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Evolução do Saldo ao Longo do Tempo',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.dividerColor.withOpacity(0.5),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < evolution.length) {
                            final monthStr = evolution[index]['month'] as String? ?? '';
                            final label = _formatMonthLabel(monthStr);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(label, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : value.toStringAsFixed(0),
                            style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withOpacity(0.1),
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

  Widget _buildReportResults(BuildContext context) {
    final theme = Theme.of(context);
    final financeProvider = context.watch<FinanceProvider>();
    
    final summary = financeProvider.reportSummary ?? {};
    final rawBreakdown = financeProvider.reportCategoryBreakdown ?? [];
    final evolution = financeProvider.reportBalanceEvolution ?? [];

    final typeLabel = _transactionType == 'all'
        ? 'todas as transações'
        : _transactionType == 'income' ? 'somente receitas' : 'somente despesas';

    final totalIncome = (summary['receita'] as num?)?.toDouble() ?? 0.0;
    final totalExpenses = (summary['despesa'] as num?)?.toDouble() ?? 0.0;
    final netIncome = (summary['liquido'] as num?)?.toDouble() ?? 0.0;
    final transactionCount = (summary['quantidade_transacoes'] as num?)?.toDouble() ?? 0.0;

    final breakdown = rawBreakdown.where((item) {
      final catName = item['category'] as String? ?? '';
      if (_selectedCategories.isNotEmpty && !_selectedCategories.contains(catName)) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Exportar
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.download, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('Exportar Relatório',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: ['PDF', 'Excel', 'CSV'].map((fmt) {
                    return OutlinedButton.icon(
                      onPressed: () => _exportReport(fmt.toLowerCase()),
                      icon: const Icon(LucideIcons.fileText, size: 16),
                      label: Text('Exportar como $fmt'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ).animate().fade(duration: 400.ms, delay: 50.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),

        const SizedBox(height: 16),

        // Resumo
        LayoutBuilder(builder: (context, constraints) {
          int cols = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: constraints.maxWidth > 500 ? 2.0 : 3.0,
            children: [
              _buildSummaryCard('Receita Total', totalIncome,
                  LucideIcons.trendingUp, const Color(0xFF10B981), 50),
              _buildSummaryCard('Despesas Totais', totalExpenses,
                  LucideIcons.trendingDown, const Color(0xFFEF4444), 100),
              _buildSummaryCard('Renda Líquida', netIncome,
                  LucideIcons.dollarSign, theme.colorScheme.primary, 150),
              _buildSummaryCard('Transações', transactionCount,
                  LucideIcons.fileText, theme.colorScheme.onSurface.withOpacity(0.7), 200,
                  isCount: true),
            ],
          );
        }),

        const SizedBox(height: 16),

        // Categoria
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Despesas por Categoria',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (breakdown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        'Nenhuma despesa registrada para o filtro selecionado.',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      ),
                    ),
                  )
                else
                  ...breakdown.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final colorHex = item['colorHex'] as String?;
                    final iconName = item['iconName'] as String?;
                    final color = _parseColor(colorHex);
                    final icon = _getIconData(iconName);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(icon, color: color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['category'] as String,
                                        style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text('${(item['percentage'] as num).toStringAsFixed(1)}% do total',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        )),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              _formatCurrency.format((item['amount'] as num?)?.toDouble() ?? 0.0),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 400.ms, delay: (50 * index).ms)
                          .slideX(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOut),
                    );
                  }),
              ],
            ),
          ),
        ).animate().fade(duration: 400.ms, delay: 250.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),

        const SizedBox(height: 16),

        // Gráfico de Evolução do Saldo
        _buildLineChartCard(evolution)
            .animate()
            .fade(duration: 400.ms, delay: 280.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),

        const SizedBox(height: 16),

        // Período do relatório
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Período do Relatório',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate.format(_startDate!)} — ${_formatDate.format(_endDate!)}',
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Este relatório inclui $typeLabel'
                  '${_selectedCategories.isNotEmpty ? ' nas categorias: ${_selectedCategories.join(', ')}' : ''}.',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fade(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double value, IconData icon, Color iconColor, int delayMs,
      {bool isCount = false}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                ),
                Icon(icon, size: 18, color: iconColor),
              ],
            ),
            Text(
              isCount ? value.toInt().toString() : _formatCurrency.format(value),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: iconColor),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 400.ms, delay: delayMs.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

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
                  'Relatórios',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ).animate().fade(duration: 300.ms).slideX(begin: -0.1, end: 0, duration: 300.ms, curve: Curves.easeOut),
              ],
            ),
            const SizedBox(height: 24),

            // Filtros
            _buildFilterCard(context)
                .animate()
                .fade(duration: 400.ms, delay: 50.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),
            const SizedBox(height: 24),

            // Resultado
            _hasReport ? _buildReportResults(context) : _buildEmptyState(context),
          ],
        ),
      ),
    );
  }
}
