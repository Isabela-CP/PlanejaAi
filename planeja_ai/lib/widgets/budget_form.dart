import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/budget.dart';
import '../providers/finance_provider.dart';
import '../core/models/category.dart';
import 'category_dialog.dart';

class BudgetForm extends StatefulWidget {
  final List<Budget> currentBudgets;
  final Function(String categoryId, double limit, int resetDay) onAddBudget;
  final VoidCallback onCancel;

  const BudgetForm({
    Key? key,
    required this.currentBudgets,
    required this.onAddBudget,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategoryId;
  final _limitController = TextEditingController();
  int _resetDay = 1;

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Por favor, selecione uma categoria.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final limitText = _limitController.text.replaceAll(',', '.');
      final limit = double.tryParse(limitText) ?? 0.0;

      widget.onAddBudget(_selectedCategoryId!, limit, _resetDay);
    }
  }

  void _showNewCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const CategoryDialog(),
    ).then((result) {
      if (result == true) {
        // Recarrega as categorias do provider
        Provider.of<FinanceProvider>(context, listen: false).fetchCategories();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Categoria criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final financeProvider = Provider.of<FinanceProvider>(context);
    
    // Filtrar categorias de transação que já não tenham orçamento
    final availableCategories = financeProvider.transactionCategories.where((cat) {
      return !widget.currentBudgets.any((b) => b.categoryId == cat.id);
    }).toList();

    if (_selectedCategoryId == null && availableCategories.isNotEmpty) {
      try {
        final outrosCat = availableCategories.firstWhere(
          (cat) => cat.name.toLowerCase() == 'outros',
        );
        _selectedCategoryId = outrosCat.id;
      } catch (_) {
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Criar Novo Orçamento',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showNewCategoryDialog(context),
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: const Text('Nova Categoria', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              if (availableCategories.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Você já definiu orçamentos para todas as categorias de transação cadastradas!',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool useRow = constraints.maxWidth >= 600;

                    Widget categoryField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Categoria',
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          hint: const Text('Selecione uma categoria'),
                          items: availableCategories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Color(cat.colorValue),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(cat.name),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCategoryId = val;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor, selecione uma categoria';
                            }
                            return null;
                          },
                        ),
                      ],
                    );

                    Widget limitField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Valor do Orçamento (R\$)',
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        TextFormField(
                          controller: _limitController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(hintText: '0.00'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, insira um valor';
                            }
                            final parsedValue = double.tryParse(
                              value.replaceAll(',', '.'),
                            );
                            if (parsedValue == null || parsedValue <= 0) {
                              return 'Insira um orçamento válido (maior que zero)';
                            }
                            return null;
                          },
                        ),
                      ],
                    );

                    Widget resetDayField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Dia do Reset Mensal',
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        DropdownButtonFormField<int>(
                          value: _resetDay,
                          items: List.generate(31, (index) => index + 1).map((day) {
                            return DropdownMenuItem<int>(
                              value: day,
                              child: Text('Dia $day'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _resetDay = val;
                              });
                            }
                          },
                        ),
                      ],
                    );

                    if (useRow) {
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: categoryField),
                              const SizedBox(width: 16),
                              Expanded(child: limitField),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: resetDayField),
                              const SizedBox(width: 16),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          categoryField,
                          const SizedBox(height: 16),
                          limitField,
                          const SizedBox(height: 16),
                          resetDayField,
                        ],
                      );
                    }
                  },
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (availableCategories.isNotEmpty)
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Criar Orçamento'),
                      ),
                    ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
