import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/models/goal.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_form.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _showForm = false;

  final List<Goal> _goals = [
    Goal(
      id: '1',
      name: 'Fundo de Emergência',
      amount: 10000,
      currentAmount: 6500,
      deadline: DateTime(2024, 12, 31),
      category: 'Emergência',
    ),
    Goal(
      id: '2',
      name: 'Viagem para Europa',
      amount: 5000,
      currentAmount: 2100,
      deadline: DateTime(2024, 8, 15),
      category: 'Viagem',
    ),
    Goal(
      id: '3',
      name: 'Notebook Novo',
      amount: 1500,
      currentAmount: 1200,
      deadline: DateTime(2024, 4, 30),
      category: 'Tecnologia',
    ),
  ];

  void _toggleForm() {
    setState(() {
      _showForm = !_showForm;
    });
  }

  void _handleAddGoal(Goal newGoal) {
    setState(() {
      _goals.add(newGoal);
      _showForm = false;
    });
  }

  void _handleDeleteGoal(String id) {
    setState(() {
      _goals.removeWhere((goal) => goal.id == id);
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
                  'Metas Financeiras',
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
              GoalForm(
                onAddGoal: _handleAddGoal,
                onCancel: _toggleForm,
              ).animate()
               .fade(duration: 300.ms)
               .slideY(begin: -0.1, end: 0, duration: 300.ms, curve: Curves.easeOut),

            Expanded(
              child: _goals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.track_changes, 
                            size: 64, 
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma meta criada ainda.\nComece criando sua primeira meta financeira!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        ],
                      ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
                        
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 310, 
                          ),
                          itemCount: _goals.length,
                          itemBuilder: (context, index) {
                            return GoalCard(
                              goal: _goals[index],
                              onDelete: () => _handleDeleteGoal(_goals[index].id),
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
