import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../core/models/category.dart';
import '../core/models/transaction.dart';
import '../providers/finance_provider.dart';
import '../widgets/category_dialog.dart';

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

const _kColorPalette = <Color>[
  Color(0xFFEF4444), Color(0xFFF97316), Color(0xFFF59E0B), Color(0xFF10B981),
  Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899),
  Color(0xFF6B7280), Color(0xFF14B8A6), Color(0xFF84CC16), Color(0xFFFF5733),
];

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _showForm = false;
  String _type = 'expense';
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _categoryFocusNode = FocusNode();
  bool _showCategoryOptions = false;
  bool _isDialogOpen = false;
  DateTime _date = DateTime.now();
  Transaction? _transactionToEdit;


  bool _isLoading = false;

  final _formatCurrency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _formatDate = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _categoryController.text = 'Outros';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FinanceProvider>();
      provider.fetchCategories();
      provider.fetchTransactions();
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
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _categoryFocusNode.dispose();
    super.dispose();
  }

  void _showCategoryDialog({AppCategory? editing, String? name}) {
    setState(() {
      _isDialogOpen = true;
    });
    showDialog(
      context: context,
      builder: (ctx) => CategoryDialog(editing: editing, initialName: name),
    ).then((result) {
      setState(() {
        _isDialogOpen = false;
      });
      if (result == true) {
        context.read<FinanceProvider>().fetchCategories();
      }
    });
  }

  Future<void> _deleteCategory(AppCategory cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Categoria'),
        content: Text('Tem certeza que deseja remover "${cat.name}" das opções salvas?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await context.read<FinanceProvider>().deleteCategory(cat.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoria removida com sucesso!')),
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

  void _handleEditTransaction(Transaction tx) {
    setState(() {
      _transactionToEdit = tx;
      _showForm = true;
      _type = tx.type;
      _titleController.text = tx.title;
      _amountController.text = tx.amount.toStringAsFixed(2).replaceAll('.', ',');
      _descriptionController.text = tx.description;
      _categoryController.text = tx.categoryName;
      _date = tx.date;
    });
  }

  Future<void> _deleteTransaction(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Transação'),
        content: const Text('Tem certeza que deseja excluir esta transação?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await context.read<FinanceProvider>().deleteTransaction(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transação excluída com sucesso!'), backgroundColor: Colors.green),
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

  Future<void> _handleSubmit() async {
    final titleText = _titleController.text.trim();
    final categoryText = _categoryController.text.trim();
    if (titleText.isEmpty || _amountController.text.isEmpty || categoryText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha o título, valor e categoria')),
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

    setState(() => _isLoading = true);

    final provider = context.read<FinanceProvider>();
    final matched = provider.transactionCategories.firstWhere(
      (c) => c.name.toLowerCase() == categoryText.toLowerCase(),
      orElse: () => AppCategory(id: '', name: '', colorHex: '', iconName: '', type: 'transaction'),
    );

    final newTransaction = Transaction(
      id: '',
      title: titleText,
      type: _type,
      amount: amount,
      categoryName: matched.id.isNotEmpty ? matched.name : categoryText,
      category: matched.id.isNotEmpty ? matched : null,
      date: _date,
      description: _descriptionController.text,
    );

    try {
      if (_transactionToEdit != null) {
        final updatedTx = _transactionToEdit!.copyWith(
          title: titleText,
          type: _type,
          amount: amount,
          categoryName: matched.id.isNotEmpty ? matched.name : categoryText,
          category: matched.id.isNotEmpty ? matched : null,
          date: _date,
          description: _descriptionController.text,
        );
        await provider.updateTransaction(_transactionToEdit!.id, updatedTx);
      } else {
        await provider.addTransaction(newTransaction);
      }

      setState(() {
        _showForm = false;
        _transactionToEdit = null;
        _titleController.clear();
        _amountController.clear();
        _descriptionController.clear();
        _categoryController.text = 'Outros';
        _showCategoryOptions = false;
        _date = DateTime.now();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transação adicionada com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Transações',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600 ? 24 : 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade().slideX(),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => setState(() {
                    _showForm = !_showForm;
                    if (!_showForm) {
                      _transactionToEdit = null;
                      _titleController.clear();
                      _amountController.clear();
                      _descriptionController.clear();
                      _categoryController.text = 'Outros';
                      _date = DateTime.now();
                    }
                    _showCategoryOptions = false;
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
                child: TapRegion(
                  onTapOutside: (event) {
                    if (!_isDialogOpen) {
                      setState(() {
                        _showCategoryOptions = false;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _transactionToEdit != null ? 'Editar Transação' : 'Nova Transação',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título da Transação',
                            hintText: 'Ex: Compra no Supermercado, Salário',
                          ),
                          onTap: () {
                            setState(() {
                              _showCategoryOptions = false;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
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
                               onTap: () {
                                  setState(() {
                                    _showCategoryOptions = false;
                                  });
                                },
                                onChanged: (val) {
                                  setState(() {
                                    _type = val!;
                                    _showCategoryOptions = false;
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
                                onTap: () {
                                  setState(() {
                                    _showCategoryOptions = false;
                                  });
                                },
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: _categoryController,
                                    focusNode: _categoryFocusNode,
                                    decoration: InputDecoration(
                                      labelText: 'Categoria',
                                      hintText: 'Selecione ou digite...',
                                      suffixIcon: IconButton(
                                        icon: Icon(_showCategoryOptions ? LucideIcons.chevronUp : LucideIcons.chevronDown),
                                        onPressed: () {
                                          if (_showCategoryOptions) {
                                            _categoryFocusNode.unfocus();
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
                              ),
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    _showCategoryOptions = false;
                                  });
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

                      if (_showCategoryOptions)
                        AnimatedContainer(
                          duration: 200.ms,
                          constraints: const BoxConstraints(maxHeight: 220),
                          margin: const EdgeInsets.only(top: 8, bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).dividerColor),
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
                              final filtered = provider.categories.where((cat) {
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
                                        'Nenhuma categoria salva.\nDigite um nome acima para começar!',
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

                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Descrição (Opcional)',
                          hintText: 'Adicione uma nota...',
                        ),
                        onTap: () {
                          setState(() {
                            _showCategoryOptions = false;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(_transactionToEdit != null ? 'Salvar Alterações' : 'Adicionar Transação'),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: () => setState(() {
                              _showForm = false;
                              _transactionToEdit = null;
                              _titleController.clear();
                              _amountController.clear();
                              _descriptionController.clear();
                              _categoryController.text = 'Outros';
                              _date = DateTime.now();
                              _showCategoryOptions = false;
                            }),
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
                    Consumer<FinanceProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoadingTransactions) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final list = provider.transactions;
                        if (list.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'Nenhuma transação ainda. Adicione sua primeira!',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final theme = Theme.of(context);
                            final t = list[index];
                            final isIncome = t.type == 'income';
                            final baseColor = isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);

                            final hasCat = t.category != null;
                            final color = hasCat ? Color(t.category!.colorValue) : baseColor;
                            final icon = hasCat
                                ? (_kIcons[t.category!.iconName] ?? LucideIcons.helpCircle)
                                : (isIncome ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft);

                            return InkWell(
                              onTap: () {},
                              hoverColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(icon, color: color, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.title,
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                          ),
                                          if (t.description.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              t.description,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.85),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 4,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: color.withOpacity(0.3)),
                                                ),
                                                child: Text(
                                                  t.categoryName,
                                                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(LucideIcons.calendar, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _formatDate.format(t.date),
                                                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
      
                                  ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    MediaQuery.of(context).size.width > 600
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${isIncome ? '+' : '-'}${_formatCurrency.format(t.amount)}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: baseColor,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              SizedBox(
                                                height: 28,
                                                width: 28,
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  iconSize: 16,
                                                  icon: const Icon(LucideIcons.edit3, color: Colors.grey),
                                                  hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                  onPressed: () => _handleEditTransaction(t),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              SizedBox(
                                                height: 28,
                                                width: 28,
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  iconSize: 16,
                                                  icon: const Icon(LucideIcons.trash2, color: Colors.grey),
                                                  hoverColor: Colors.red.withOpacity(0.1),
                                                  onPressed: () => _deleteTransaction(t.id),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${isIncome ? '+' : '-'}${_formatCurrency.format(t.amount)}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: baseColor,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    height: 28,
                                                    width: 28,
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      iconSize: 16,
                                                      icon: const Icon(LucideIcons.edit3, color: Colors.grey),
                                                      hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                      onPressed: () => _handleEditTransaction(t),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  SizedBox(
                                                    height: 28,
                                                    width: 28,
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      iconSize: 16,
                                                      icon: const Icon(LucideIcons.trash2, color: Colors.grey),
                                                      hoverColor: Colors.red.withOpacity(0.1),
                                                      onPressed: () => _deleteTransaction(t.id),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            ).animate().fade(duration: 400.ms, delay: (50 * index).ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
                          },
                        );
                      },
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


