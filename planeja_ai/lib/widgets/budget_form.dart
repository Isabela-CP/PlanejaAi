import 'package:flutter/material.dart';
import '../core/models/budget.dart';

class BudgetForm extends StatefulWidget {
  final List<Budget> currentBudgets;
  final Function(Budget) onAddBudget;
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
  final _categoryController = TextEditingController();
  final _limitController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final category = _categoryController.text.trim();
      final limitText = _limitController.text.replaceAll(',', '.');
      final limitStr = limitText.isEmpty ? '0' : limitText;
      final limit = double.tryParse(limitStr) ?? 0.0;

      // Checar se já existe
      final exists = widget.currentBudgets.any(
        (b) => b.category.toLowerCase() == category.toLowerCase(),
      );
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Um orçamento para $category já existe.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final newBudget = Budget(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: category,
        monthlyLimit: limit,
        spent: 0,
        createdAt: DateTime.now(),
      );

      widget.onAddBudget(newBudget);

      // Snackbar de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Orçamento de R\$$limitStr definido para $category com sucesso!',
          ),
          backgroundColor: Colors
              .green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Text(
                'Criar Novo Orçamento',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
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
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          hintText: 'ex: Alimentação, Transporte, etc.',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, insira uma categoria';
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

                  if (useRow) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: categoryField),
                        const SizedBox(width: 16),
                        Expanded(child: limitField),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        categoryField,
                        const SizedBox(height: 16),
                        limitField,
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
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
