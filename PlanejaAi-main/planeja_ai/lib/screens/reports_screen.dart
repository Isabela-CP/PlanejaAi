import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  final List<String> _categories = [
    'Alimentação', 'Transporte', 'Entretenimento',
    'Contas', 'Compras', 'Saúde', 'Educação', 'Outros',
  ];

  final _transactionTypes = [
    {'value': 'all', 'label': 'Todas as Transações'},
    {'value': 'income', 'label': 'Somente Receitas'},
    {'value': 'expense', 'label': 'Somente Despesas'},
  ];

  // Dados mock
  final _mockSummary = {
    'totalIncome': 16200.0,
    'totalExpenses': 9720.0,
    'netIncome': 6480.0,
    'transactionCount': 45,
  };

  final _mockCategoryBreakdown = [
    {'category': 'Alimentação', 'amount': 2450.0, 'percentage': 25.2},
    {'category': 'Transporte', 'amount': 1890.0, 'percentage': 19.4},
    {'category': 'Contas', 'amount': 2850.0, 'percentage': 29.3},
    {'category': 'Entretenimento', 'amount': 960.0, 'percentage': 9.9},
    {'category': 'Compras', 'amount': 1570.0, 'percentage': 16.2},
  ];

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

  void _generateReport() {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, selecione as datas de início e fim.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (!_startDate!.isBefore(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('A data de início deve ser anterior à data de fim.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _hasReport = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relatório gerado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _exportReport(String format) {
    if (!_hasReport) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gere um relatório antes de exportar.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exportando como ${format.toUpperCase()}...')),
    );
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
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              Widget startDateField = _buildDateField(
                label: 'Data de Início',
                value: _startDate,
                onTap: () => _pickDate(isStart: true),
              );
              Widget endDateField = _buildDateField(
                label: 'Data de Fim',
                value: _endDate,
                onTap: () => _pickDate(isStart: false),
              );
              Widget typeField = Column(
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
              );
              Widget generateBtn = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isWide) const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('', style: theme.textTheme.titleSmall),
                  ),
                  ElevatedButton.icon(
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: startDateField),
                    const SizedBox(width: 16),
                    Expanded(child: endDateField),
                    const SizedBox(width: 16),
                    Expanded(child: typeField),
                    const SizedBox(width: 16),
                    Expanded(child: generateBtn),
                  ],
                );
              } else {
                return Column(children: [
                  startDateField,
                  const SizedBox(height: 16),
                  endDateField,
                  const SizedBox(height: 16),
                  typeField,
                  const SizedBox(height: 16),
                  generateBtn,
                ]);
              }
            }),

            const SizedBox(height: 24),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 16),

            // Categorias
            Text('Categorias (vazio = todas)',
                style: theme.textTheme.titleSmall?.copyWith(color: mutedColor)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
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

  Widget _buildReportResults(BuildContext context) {
    final theme = Theme.of(context);
    final typeLabel = _transactionType == 'all'
        ? 'todas as transações'
        : _transactionType == 'income' ? 'somente receitas' : 'somente despesas';

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
              _buildSummaryCard('Receita Total', _mockSummary['totalIncome'] as double,
                  LucideIcons.trendingUp, const Color(0xFF10B981), 50),
              _buildSummaryCard('Despesas Totais', _mockSummary['totalExpenses'] as double,
                  LucideIcons.trendingDown, const Color(0xFFEF4444), 100),
              _buildSummaryCard('Renda Líquida', _mockSummary['netIncome'] as double,
                  LucideIcons.dollarSign, theme.colorScheme.primary, 150),
              _buildSummaryCard('Transações', (_mockSummary['transactionCount'] as int).toDouble(),
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
                ..._mockCategoryBreakdown.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['category'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('${item['percentage']}% do total',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  )),
                            ],
                          ),
                          Text(
                            _formatCurrency.format(item['amount']),
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
