import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/models/goal.dart';
import '../core/models/category.dart';
import '../providers/finance_provider.dart';
import 'category_dialog.dart';

const _kIcons = <String, IconData>{
  'utensils': LucideIcons.utensils,
  'car': LucideIcons.car,
  'palmtree': LucideIcons.palmtree,
  'home': LucideIcons.home,
  'trending-up': LucideIcons.trendingUp,
  'shopping-cart': LucideIcons.shoppingCart,
  'bus': LucideIcons.bus,
  'ticket': LucideIcons.ticket,
  'sandwich': LucideIcons.sandwich,
  'book-open': LucideIcons.bookOpen,
  'help-circle': LucideIcons.helpCircle,
  'heart': LucideIcons.heart,
  'briefcase': LucideIcons.briefcase,
  'music': LucideIcons.music,
  'gamepad-2': LucideIcons.gamepad2,
  'plane': LucideIcons.plane,
  'dumbbell': LucideIcons.dumbbell,
  'baby': LucideIcons.baby,
  'shirt': LucideIcons.shirt,
  'wifi': LucideIcons.wifi,
  'zap': LucideIcons.zap,
  'gift': LucideIcons.gift,
  'coffee': LucideIcons.coffee,
  'dollar-sign': LucideIcons.dollarSign,
  'piggy-bank': LucideIcons.piggyBank,
  'graduation-cap': LucideIcons.graduationCap,
  'stethoscope': LucideIcons.stethoscope,
  'paw-print': LucideIcons.pawPrint,
  'film': LucideIcons.film,
};


class GoalForm extends StatefulWidget {
  final Function(Goal) onAddGoal;
  final VoidCallback onCancel;
  final Goal? goalToEdit;

  const GoalForm({
    Key? key,
    required this.onAddGoal,
    required this.onCancel,
    this.goalToEdit,
  }) : super(key: key);

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _categoryFocusNode = FocusNode();
  
  DateTime? _selectedDate;
  bool _showCategoryOptions = false;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    if (widget.goalToEdit != null) {
      _nameController.text = widget.goalToEdit!.name;
      _amountController.text = widget.goalToEdit!.amount.toStringAsFixed(2).replaceAll('.', ',');
      _categoryController.text = widget.goalToEdit!.category;
      _selectedDate = widget.goalToEdit!.deadline;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().fetchCategories(type: 'goal');
    });

    _categoryFocusNode.addListener(() {
      if (_categoryFocusNode.hasFocus) {
        setState(() {
          _showCategoryOptions = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _categoryFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final categoryName = _categoryController.text.trim();
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final name = _nameController.text.trim();
      final limitText = _amountController.text.replaceAll(',', '.');
      final limitStr = limitText.isEmpty ? '0' : limitText;
      final amount = double.tryParse(limitStr) ?? 0.0;
      
      final provider = context.read<FinanceProvider>();
      String? categoryId;
      String? customCategory;

      if (categoryName.isNotEmpty) {
        final matchedCategory = provider.goalCategories.firstWhere(
          (cat) => cat.name.toLowerCase() == categoryName.toLowerCase(),
          orElse: () => const AppCategory(id: '', name: '', colorHex: '', iconName: ''),
        );

        if (matchedCategory.id.isEmpty) {
          customCategory = categoryName;
        } else {
          categoryId = matchedCategory.id;
        }
      }

      final goalData = Goal(
        id: widget.goalToEdit?.id ?? '',
        name: name,
        amount: amount,
        currentAmount: widget.goalToEdit?.currentAmount ?? 0.0,
        deadline: _selectedDate!,
        categoryId: categoryId,
        customCategory: customCategory,
      );

      try {
        if (widget.goalToEdit != null) {
          await provider.updateGoal(
            widget.goalToEdit!.id,
            name: name,
            amount: amount,
            deadline: _selectedDate,
            categoryId: categoryId,
            customCategory: customCategory,
          );
        } else {
          await provider.addGoal(goalData);
        }
        widget.onAddGoal(goalData);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar meta: ${e.toString().replaceFirst('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
      child: TapRegion(
        onTapOutside: (event) {
          if (!_isDialogOpen) {
            setState(() {
              _showCategoryOptions = false;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(widget.goalToEdit != null ? Icons.edit_note : Icons.track_changes, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      widget.goalToEdit != null ? 'Editar Meta Financeira' : 'Criar Nova Meta Financeira',
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
                          onTap: () {
                            setState(() {
                              _showCategoryOptions = false;
                            });
                          },
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
                          onTap: () {
                            setState(() {
                              _showCategoryOptions = false;
                            });
                          },
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
                          onTap: () async {
                            setState(() {
                              _showCategoryOptions = false;
                            });
                            await _pickDate();
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              hintText: 'Selecione uma data',
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
                        TextField(
                          controller: _categoryController,
                          focusNode: _categoryFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Selecione ou digite...',
                            suffixIcon: IconButton(
                              icon: Icon(_showCategoryOptions ? LucideIcons.chevronUp : LucideIcons.chevronDown),
                              onPressed: () {
                                if (_showCategoryOptions) {
                                  _categoryFocusNode.unfocus();
                                  setState(() {
                                    _showCategoryOptions = false;
                                  });
                                } else {
                                  _categoryFocusNode.requestFocus();
                                }
                              },
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _showCategoryOptions = true;
                            });
                          },
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
                
                if (_showCategoryOptions)
                  AnimatedContainer(
                    duration: 200.ms,
                    constraints: const BoxConstraints(maxHeight: 220),
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Consumer<FinanceProvider>(
                      builder: (context, provider, _) {
                        final query = _categoryController.text.trim().toLowerCase();
                        final exactMatch = provider.goalCategories.any((c) => c.name.toLowerCase() == query);
                        final filtered = exactMatch
                            ? provider.goalCategories
                            : provider.goalCategories.where((cat) {
                                return cat.name.toLowerCase().contains(query);
                              }).toList();

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (query.isNotEmpty && !filtered.any((c) => c.name.toLowerCase() == query))
                              ListTile(
                                leading: const Icon(LucideIcons.plusCircle, color: Colors.blue),
                                title: Text("Salvar '$query' como fixa"),
                                subtitle: const Text('Ficará disponível como opção pronta'),
                                onTap: () {
                                  _showCategoryDialog(name: _categoryController.text.trim());
                                },
                              ),
                            if (provider.isLoadingCategories)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (filtered.isEmpty && query.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Nenhuma categoria de meta salva.\nDigite um nome acima para começar!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              )
                            else
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filtered.length,
                                  itemBuilder: (ctx, idx) {
                                    final cat = filtered[idx];
                                    final color = Color(cat.colorValue);
                                    final icon = _kIcons[cat.iconName] ?? LucideIcons.helpCircle;

                                    return ListTile(
                                      dense: true,
                                      leading: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(icon, color: color, size: 14),
                                      ),
                                      title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(LucideIcons.edit3, size: 14),
                                            onPressed: () => _showCategoryDialog(editing: cat),
                                          ),
                                          IconButton(
                                            icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.red),
                                            onPressed: () => _deleteCategory(cat),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _categoryController.text = cat.name;
                                          _showCategoryOptions = false;
                                          _categoryFocusNode.unfocus();
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ).animate().fade(duration: 150.ms).slideY(begin: -0.05, end: 0, duration: 150.ms),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: Icon(widget.goalToEdit != null ? Icons.save : Icons.add, size: 18),
                        label: Text(widget.goalToEdit != null ? 'Salvar Alterações' : 'Criar Meta'),
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
      ),
    );
  }

  void _showCategoryDialog({AppCategory? editing, String? name}) {
    setState(() {
      _isDialogOpen = true;
    });
    showDialog(
      context: context,
      builder: (ctx) => CategoryDialog(editing: editing, initialName: name, type: 'goal'),
    ).then((result) {
      if (!mounted) return;
      setState(() {
        _isDialogOpen = false;
      });
      if (result == true) {
        context.read<FinanceProvider>().fetchCategories(type: 'goal');
      }
    });
  }

  Future<void> _deleteCategory(AppCategory cat) async {
    try {
      await context.read<FinanceProvider>().deleteCategory(cat.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoria removida com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }
}
