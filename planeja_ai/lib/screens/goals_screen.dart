import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/models/goal.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_form.dart';
import '../providers/finance_provider.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().fetchGoals();
      context.read<FinanceProvider>().fetchCategories(type: 'goal');
    });
  }

  void _toggleForm() {
    setState(() {
      _showForm = !_showForm;
    });
  }

  void _handleAddGoal(Goal newGoal) {
    setState(() {
      _showForm = false;
    });
  }

  Future<void> _handleDeleteGoal(String id) async {
    try {
      await context.read<FinanceProvider>().deleteGoal(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Meta removida com sucesso!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao remover: ${e.toString().replaceFirst('Exception: ', '')}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CustomScrollView(
          slivers: [
            // Header estilo Painel/Transações
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Metas Financeiras',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 600
                                ? 24
                                : 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fade(duration: 300.ms).slideX(
                            begin: -0.1,
                            end: 0,
                            duration: 300.ms,
                            curve: Curves.easeOut),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _toggleForm,
                        icon:
                            Icon(_showForm ? Icons.close : Icons.add, size: 16),
                        label: Text(_showForm ? 'Fechar' : 'Adicionar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                      ).animate().fade().scale(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_showForm)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: GoalForm(
                        onAddGoal: _handleAddGoal,
                        onCancel: _toggleForm,
                      ).animate().fade(duration: 300.ms).slideY(
                          begin: -0.1,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOut),
                    ),
                ],
              ),
            ),

            Consumer<FinanceProvider>(
              builder: (context, financeProvider, child) {
                if (financeProvider.isLoadingGoals) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final goals = financeProvider.goals;
                if (goals.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.track_changes,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4)),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma meta criada ainda.\nComece criando sua primeira meta financeira!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6)),
                          ),
                        ],
                      )
                          .animate()
                          .fade(duration: 400.ms)
                          .scale(begin: const Offset(0.9, 0.9)),
                    ),
                  );
                }

                return SliverLayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.crossAxisExtent > 800
                        ? 3
                        : (constraints.crossAxisExtent > 500 ? 2 : 1);

                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 375,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return GoalCard(
                            goal: goals[index],
                            onDelete: () => _handleDeleteGoal(goals[index].id),
                          )
                              .animate()
                              .fade(duration: 400.ms, delay: (50 * index).ms)
                              .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  duration: 400.ms,
                                  curve: Curves.easeOut);
                        },
                        childCount: goals.length,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
