import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/models/budget.dart';
import '../widgets/budget_card.dart';
import '../widgets/budget_form.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({Key? key}) : super(key: key);

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  bool _showForm = false;

  final List<Budget> _budgets = [
    Budget(
      id: '1',
      category: 'Alimentação',
      monthlyLimit: 600,
      spent: 450,
      createdAt: DateTime(2025, 1, 1),
    ),
    Budget(
      id: '2',
      category: 'Entretenimento',
      monthlyLimit: 200,
      spent: 220,
      createdAt: DateTime(2025, 1, 1),
    ),
    Budget(
      id: '3',
      category: 'Transporte',
      monthlyLimit: 400,
      spent: 120,
      createdAt: DateTime(2025, 1, 1),
    ),
    Budget(
      id: '4',
      category: 'Compras',
      monthlyLimit: 300,
      spent: 180,
      createdAt: DateTime(2025, 1, 1),
    ),
  ];

  void _toggleForm() {
    setState(() {
      _showForm = !_showForm;
    });
  }

  void _handleAddBudget(Budget newBudget) {
    setState(() {
      _budgets.add(newBudget);
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header estilo Painel/Transações
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Orçamentos',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ).animate().fade(duration: 300.ms).slideX(begin: -0.1, end: 0, duration: 300.ms, curve: Curves.easeOut),
                ElevatedButton.icon(
                  onPressed: _toggleForm,
                  icon: Icon(_showForm ? Icons.close : Icons.add, size: 16),
                  label: Text(_showForm ? 'Fechar' : 'Adicionar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ).animate().fade().scale(),
              ],
            ),
            const SizedBox(height: 24),

            if (_showForm)
              BudgetForm(
                currentBudgets: _budgets,
                onAddBudget: _handleAddBudget,
                onCancel: _toggleForm,
              ).animate()
               .fade(duration: 300.ms)
               .slideY(begin: -0.1, end: 0, duration: 300.ms, curve: Curves.easeOut),

            Expanded(
              child: _budgets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum orçamento configurado ainda.\nCrie um para começar a planejar!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        ],
                      ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        bool useTwoColumns = constraints.maxWidth >= 600;
                        
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: useTwoColumns ? 2 : 1,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 270, 
                          ),
                          itemCount: _budgets.length,
                          itemBuilder: (context, index) {
                            return BudgetCard(
                              budget: _budgets[index],
                            )
                            .animate()
                            .fade(duration: 400.ms, delay: (50 * index).ms)
                            .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
