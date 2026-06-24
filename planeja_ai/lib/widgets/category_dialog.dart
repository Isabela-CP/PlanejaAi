import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/models/category.dart';
import '../providers/finance_provider.dart';

const _kColorPalette = <Color>[
  Color(0xFFEF4444), Color(0xFFF97316), Color(0xFFF59E0B), Color(0xFF10B981),
  Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899),
  Color(0xFF6B7280), Color(0xFF14B8A6), Color(0xFF84CC16), Color(0xFFFF5733),
];

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

class CategoryDialog extends StatefulWidget {
  final AppCategory? editing;
  final String? initialName;
  final String type;

  const CategoryDialog({
    Key? key,
    this.editing,
    this.initialName,
    this.type = 'transaction',
  }) : super(key: key);

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final _nameController = TextEditingController();
  Color _selectedColor = _kColorPalette.first;
  String _selectedIcon = 'help-circle';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      _nameController.text = widget.editing!.name;
      _selectedColor = Color(widget.editing!.colorValue);
      _selectedIcon = widget.editing!.iconName;
    } else if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return '#${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome obrigatório')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final provider = context.read<FinanceProvider>();
    final newCat = AppCategory(
      id: widget.editing?.id ?? '',
      name: name,
      colorHex: _colorToHex(_selectedColor),
      iconName: _selectedIcon,
      type: widget.type,
    );
    try {
      if (widget.editing == null) {
        await provider.addCategory(newCat);
      } else {
        await provider.updateCategory(widget.editing!.id, newCat);
      }
      if (mounted) Navigator.pop(context, true);
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
    final theme = Theme.of(context);
    final isEditing = widget.editing != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Categoria' : 'Nova Categoria'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome da categoria'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),

              // Color picker
              Text('Cor', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kColorPalette.map((c) {
                  final isSelected = _selectedColor.value == c.value;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 6)]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Icon picker
              Text('Ícone', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: GridView.count(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: _kIcons.entries.map((entry) {
                    final isSelected = _selectedIcon == entry.key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = entry.key),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withOpacity(0.15)
                              : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? _selectedColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          entry.value,
                          color: isSelected ? _selectedColor : theme.colorScheme.onSurface.withOpacity(0.6),
                          size: 20,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Preview
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Text('Prévia', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _selectedColor.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_kIcons[_selectedIcon] ?? LucideIcons.helpCircle, color: _selectedColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _nameController.text.isEmpty ? 'Minha Categoria' : _nameController.text,
                            style: TextStyle(color: _selectedColor, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(isEditing ? 'Salvar' : 'Salvar Categoria'),
        ),
      ],
    );
  }
}
