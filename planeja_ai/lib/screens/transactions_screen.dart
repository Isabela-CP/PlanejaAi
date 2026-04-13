import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final String type;
  final double amount;
  final String category;
  final DateTime date;
  final String description;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });
}

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _showForm = false;
  String _type = 'expense';
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _category;
  DateTime _date = DateTime.now();

  final Map<String, List<String>> _categories = {
    'income': ['Salário', 'Freelance', 'Investimento', 'Negócio', 'Outro'],
    'expense': ['Alimentação', 'Transporte', 'Entretenimento', 'Contas', 'Compras', 'Saúde', 'Educação', 'Outro'],
  };

  List<Transaction> _transactions = [
    Transaction(
      id: '1',
      type: 'income',
      amount: 3500,
      category: 'Salário',
      date: DateTime(2024, 1, 15),
      description: 'Salário mensal',
    ),
    Transaction(
      id: '2',
      type: 'expense',
      amount: 250,
      category: 'Alimentação',
      date: DateTime(2024, 1, 14),
      description: 'Compras no supermercado',
    ),
    Transaction(
      id: '3',
      type: 'expense',
      amount: 80,
      category: 'Transporte',
      date: DateTime(2024, 1, 13),
      description: 'Gasolina',
    ),
  ];

  final _formatCurrency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _formatDate = DateFormat('dd/MM/yyyy');

  void _handleSubmit() {
    if (_amountController.text.isEmpty || _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha valor e categoria')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valor inválido')),
      );
      return;
    }

    final newTransaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      amount: amount,
      category: _category!,
      date: _date,
      description: _descriptionController.text,
    );

    setState(() {
      _transactions.insert(0, newTransaction);
      _showForm = false;
      _amountController.clear();
      _descriptionController.clear();
      _category = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transação adicionada com sucesso!')),
    );
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
                  'Transações',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ).animate().fade().slideX(),
                ElevatedButton.icon(
                  onPressed: () => setState(() {
                    _showForm = !_showForm;
                    if (_category != null && !_categories[_type]!.contains(_category)) {
                      _category = null;
                    }
                  }),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Adicionar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ).animate().fade().scale(),
              ],
            ),
            const SizedBox(height: 24),

            // Form
            if (_showForm) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nova Transação',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return GridView.count(
                            crossAxisCount: constraints.maxWidth > 600 ? 2 : 1,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: constraints.maxWidth > 600 ? 4 : 5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              DropdownButtonFormField<String>(
                                value: _type,
                                decoration: const InputDecoration(labelText: 'Tipo'),
                                items: const [
                                  DropdownMenuItem(value: 'income', child: Text('Receita')),
                                  DropdownMenuItem(value: 'expense', child: Text('Despesa')),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _type = val!;
                                    _category = null;
                                  });
                                },
                              ),
                              TextField(
                                controller: _amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Valor (R\$)',
                                  hintText: '0.00',
                                ),
                              ),
                              DropdownButtonFormField<String>(
                                value: _category,
                                decoration: const InputDecoration(labelText: 'Categoria'),
                                hint: const Text('Selecione'),
                                items: _categories[_type]!
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (val) => setState(() => _category = val),
                              ),
                              InkWell(
                                onTap: () async {
                                  final selected = await showDatePicker(
                                    context: context,
                                    initialDate: _date,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (selected != null) {
                                    setState(() => _date = selected);
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(labelText: 'Data'),
                                  child: Text(_formatDate.format(_date)),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Descrição (Opcional)',
                          hintText: 'Adicione uma nota...',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: const Text('Adicionar Transação'),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: () => setState(() => _showForm = false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fade().slideY(),
              const SizedBox(height: 24),
            ],

            // List
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transações Recentes',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    if (_transactions.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'Nenhuma transação ainda. Adicione sua primeira!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _transactions.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final t = _transactions[index];
                          final isIncome = t.type == 'income';
                          final color = isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                          
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            hoverColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isIncome ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
                                color: color,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              t.description.isNotEmpty ? t.description : t.category,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    t.category,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(LucideIcons.calendar, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate.format(t.date),
                                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                            trailing: Text(
                              '${isIncome ? '+' : '-'}${_formatCurrency.format(t.amount)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ).animate().fade(delay: 200.ms).slideY(),
          ],
        ),
      ),
    );
  }
}
