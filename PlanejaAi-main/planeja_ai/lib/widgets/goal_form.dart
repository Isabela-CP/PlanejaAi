import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/models/goal.dart';

class GoalForm extends StatefulWidget {
  final Function(Goal) onAddGoal;
  final VoidCallback onCancel;

  const GoalForm({
    Key? key,
    required this.onAddGoal,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;

  final List<String> categories = ['Emergência', 'Viagem', 'Tecnologia', 'Educação', 'Investimento', 'Casa', 'Saúde', 'Outros'];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedCategory != null) {
      final name = _nameController.text.trim();
      final limitText = _amountController.text.replaceAll(',', '.');
      final limitStr = limitText.isEmpty ? '0' : limitText;
      final amount = double.tryParse(limitStr) ?? 0.0;
      
      final newGoal = Goal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        amount: amount,
        currentAmount: 0,
        deadline: _selectedDate!,
        category: _selectedCategory!,
      );

      widget.onAddGoal(newGoal);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meta "$name" criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, preencha todos os campos e selecione o prazo.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('dd/MM/yyyy');

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
                children: [
                  Icon(Icons.track_changes, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Criar Nova Meta Financeira',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  bool useRow = constraints.maxWidth >= 600;

                  Widget nameField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text('Nome da Meta', style: theme.textTheme.titleSmall),
                      ),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'ex: Fundo de Emergência, Carro',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Por favor, insira um nome';
                          return null;
                        },
                      ),
                    ],
                  );

                  Widget amountField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text('Valor Alvo (R\$)', style: theme.textTheme.titleSmall),
                      ),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Por favor, insira um valor';
                          final parsedValue = double.tryParse(value.replaceAll(',', '.'));
                          if (parsedValue == null || parsedValue <= 0) return 'Insira um valor maior que zero';
                          return null;
                        },
                      ),
                    ],
                  );

                  Widget dateField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text('Prazo', style: theme.textTheme.titleSmall),
                      ),
                      InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            hintText: 'Selecione uma data',
                            errorText: _selectedDate == null && false ? 'Obrigatório' : null, // simplificado via submit
                          ),
                          child: Text(
                            _selectedDate == null ? 'Selecione uma data' : dateFormatter.format(_selectedDate!),
                            style: TextStyle(color: _selectedDate == null ? Colors.grey : null),
                          ),
                        ),
                      ),
                    ],
                  );

                  Widget categoryField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text('Categoria', style: theme.textTheme.titleSmall),
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) {
                          setState(() { _selectedCategory = val; });
                        },
                        validator: (value) => value == null ? 'Por favor, selecione uma categoria' : null,
                        decoration: const InputDecoration(hintText: 'Selecione'),
                      ),
                    ],
                  );

                  if (useRow) {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [ Expanded(child: nameField), const SizedBox(width: 16), Expanded(child: amountField) ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [ Expanded(child: dateField), const SizedBox(width: 16), Expanded(child: categoryField) ],
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        nameField,
                        const SizedBox(height: 16),
                        amountField,
                        const SizedBox(height: 16),
                        dateField,
                        const SizedBox(height: 16),
                        categoryField,
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
                    child: ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Criar Meta'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: widget.onCancel,
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
      ),
    );
  }
}
