import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// Revert prompt 09: remove dialog and navigation imports
import 'daily_goal_entity_form_dialog.dart';
import 'dialogs/daily_goal_actions_dialog.dart';
import '../../../domain/entities/daily_goal_entity.dart';
import '../../../providers/profile_provider.dart';

class DailyGoalListPage extends ConsumerStatefulWidget {
  const DailyGoalListPage({super.key});

  @override
  ConsumerState<DailyGoalListPage> createState() => _DailyGoalListPageState();
}

class _DailyGoalListPageState extends ConsumerState<DailyGoalListPage>
    with SingleTickerProviderStateMixin {
  // Simulação de estado local (não persistente) - UI only
  bool showTip = true;
  bool _isLoading = false;

  // Sample data for UI demonstration only (not persisted)
  // Accepts both Map<String,dynamic> (DTO-like) and DailyGoalEntity
  final List<dynamic> _sampleGoals = [
    {
      'goal_id': '1',
      'uid': 'user1',
      'goal_type': 'mood_entries',
      'target': 3,
      'current': 2,
      'date_iso': DateTime.now().toIso8601String(),
      'completed': false,
    },
    {
      'goal_id': '2',
      'uid': 'user1',
      'goal_type': 'meditation_minutes',
      'target': 15,
      'current': 15,
      'date_iso':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'completed': true,
    },
    {
      'goal_id': '3',
      'uid': 'user1',
      'goal_type': 'water_glasses',
      'target': 8,
      'current': 5,
      'date_iso': DateTime.now().toIso8601String(),
      'completed': false,
    },
  ];

  late final AnimationController _fabController;
  late final Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fabScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticInOut),
    );
    if (showTip) _fabController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas Diárias'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(context),
          ),

          // Opt-out button positioned bottom-left
          if (showTip)
            Positioned(
              left: 16,
              bottom: MediaQuery.of(context).padding.bottom + 12,
              child: TextButton(
                onPressed: () => setState(() {
                  showTip = false;
                  _fabController.stop();
                  _fabController.reset();
                }),
                child: const Text(
                  'Não exibir dica novamente',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

          // Tip bubble positioned above FAB (bottom-right)
          if (showTip)
            Positioned(
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 72,
              child: AnimatedBuilder(
                animation: _fabController,
                builder: (context, child) {
                  final v = _fabController.value;
                  return Transform.translate(
                    offset: Offset(0, 10 * (1 - v)),
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'Toque aqui para adicionar uma meta',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      // Standard FAB at bottom-right with subtle scale animation
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: FloatingActionButton(
          onPressed: () async {
            // Abre a dialog para criar/editar uma meta diária
            // Integrar userId do perfil atual
            final profile = ref.read(profileProvider);
            final result = await showDailyGoalEntityFormDialog(
              context,
              userId: profile.email ?? 'user1',
            );
            if (!mounted) return;
            if (result != null) {
              if (!mounted) return;
              setState(() {
                // UI only - not persisted
                _sampleGoals.insert(0, result);
              });
              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('Meta adicionada (apenas UI)')),
              );
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_sampleGoals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flag_outlined,
                size: 72,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha((0.3 * 255).round()),
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma meta cadastrada ainda.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Use o botão abaixo para criar sua primeira meta diária.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // UI only - simulate refresh
        setState(() {
          _isLoading = true;
        });
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _isLoading = false;
        });
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _sampleGoals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final goal = _sampleGoals[index];
          return _buildDismissibleGoalCard(context, goal, index);
        },
      ),
    );
  }

  /// Envolver o card com Dismissible para swipe-to-delete
  Widget _buildDismissibleGoalCard(BuildContext context, dynamic goal, int index) {
    // Extrair ID para usar como key do Dismissible
    String goalId;
    if (goal is DailyGoalEntity) {
      goalId = goal.id;
    } else if (goal is Map<String, dynamic>) {
      goalId = goal['goal_id'] as String? ?? 'goal_$index';
    } else {
      goalId = 'goal_$index';
    }

    return Dismissible(
      key: Key(goalId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        // Reutilizar diálogo de confirmação existente
        return await _showRemoveConfirmationDialog();
      },
      onDismissed: (direction) {
        // Remover da lista
        setState(() {
          _sampleGoals.removeAt(index);
        });

        // Feedback visual
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meta removida com sucesso!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      child: _buildGoalCard(context, goal),
    );
  }

  Widget _buildGoalCard(BuildContext context, dynamic goal) {
    // Normalize fields whether goal is Map or DailyGoalEntity
    late final String goalTypeKey;
    late final int target;
    late final int current;
    late final bool completed;
    late final DateTime dateTime;

    if (goal is DailyGoalEntity) {
      goalTypeKey = goal.type.name; // e.g., moodEntries
      target = goal.targetValue;
      current = goal.currentValue;
      completed = goal.isCompleted || goal.isAchieved;
      dateTime = goal.date;
    } else if (goal is Map<String, dynamic>) {
      goalTypeKey = (goal['goal_type'] as String?) ?? 'unknown';
      target = (goal['target'] as int?) ?? 0;
      current = (goal['current'] as int?) ?? 0;
      completed = (goal['completed'] as bool?) ?? false;
      final dateIso =
          (goal['date_iso'] as String?) ?? DateTime.now().toIso8601String();
      dateTime = DateTime.tryParse(dateIso) ?? DateTime.now();
    } else {
      // Fallback: render empty card
      goalTypeKey = 'unknown';
      target = 0;
      current = 0;
      completed = false;
      dateTime = DateTime.now();
    }

    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final dateFormatted = DateFormat('dd/MM/yyyy').format(dateTime);

    return GestureDetector(
      onLongPress: () => _handleGoalSelection(goal),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: completed
            ? BorderSide(color: Colors.green.shade300, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildGoalTypeChip(goalTypeKey),
                          const SizedBox(width: 8),
                          if (completed)
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade600,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getGoalTypeLabel(goalTypeKey),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dateFormatted,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha((0.6 * 255).round()),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$current / $target',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: completed ? Colors.green.shade700 : null,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha((0.1 * 255).round()),
                valueColor: AlwaysStoppedAnimation<Color>(
                  completed
                      ? Colors.green.shade600
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% completo',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha((0.6 * 255).round()),
                  ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// Manipula a seleção de uma meta (long-press)
  Future<void> _handleGoalSelection(dynamic goal) async {
    final action = await showDailyGoalActionsDialog(context);
    if (!mounted) return;
    if (action == null) return;

    switch (action) {
      case DailyGoalAction.edit:
        await _handleEditGoal(goal);
        break;
      case DailyGoalAction.remove:
        await _handleRemoveGoal(goal);
        break;
      case DailyGoalAction.close:
        // Apenas fecha o diálogo (já foi fechado)
        break;
    }
  }

  /// Edita uma meta existente
  Future<void> _handleEditGoal(dynamic goal) async {
    // Converter para DailyGoalEntity se necessário
    DailyGoalEntity? entity;
    
    if (goal is DailyGoalEntity) {
      entity = goal;
    } else if (goal is Map<String, dynamic>) {
      // Converter Map para DailyGoalEntity para edição
      final goalTypeStr = (goal['goal_type'] as String?) ?? '';
      final GoalType goalType = GoalType.values.firstWhere(
        (e) => e.name == goalTypeStr,
        orElse: () => GoalType.moodEntries,
      );
      
      entity = DailyGoalEntity(
        id: goal['goal_id'] as String? ?? '',
        userId: goal['uid'] as String? ?? '',
        type: goalType,
        targetValue: (goal['target'] as int?) ?? 0,
        currentValue: (goal['current'] as int?) ?? 0,
        date: DateTime.tryParse(goal['date_iso'] as String? ?? '') ?? DateTime.now(),
        isCompleted: (goal['completed'] as bool?) ?? false,
      );
    }

    if (entity == null) return;

    final profile = ref.read(profileProvider);
    final result = await showDailyGoalEntityFormDialog(
      context,
      initial: entity,
      userId: profile.email ?? 'user1',
    );
    if (!mounted) return;
    if (result != null && mounted) {
      setState(() {
        // Encontrar e atualizar a meta na lista
        final index = _sampleGoals.indexWhere((g) {
          if (g is DailyGoalEntity) {
            return g.id == result.id;
          } else if (g is Map<String, dynamic>) {
            return g['goal_id'] == result.id;
          }
          return false;
        });

        if (index >= 0) {
          _sampleGoals[index] = result;
        }
      });

      // Feedback visual
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meta atualizada com sucesso!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Remove uma meta após confirmação
  Future<void> _handleRemoveGoal(dynamic goal) async {
    // Extrair ID da meta
    String? goalId;
    if (goal is DailyGoalEntity) {
      goalId = goal.id;
    } else if (goal is Map<String, dynamic>) {
      goalId = goal['goal_id'] as String?;
    }

    if (goalId == null) return;

    // Diálogo de confirmação
    final confirmed = await _showRemoveConfirmationDialog();
    if (!mounted) return;

    if (confirmed == true && mounted) {
      setState(() {
        _sampleGoals.removeWhere((g) {
          if (g is DailyGoalEntity) {
            return g.id == goalId;
          } else if (g is Map<String, dynamic>) {
            return g['goal_id'] == goalId;
          }
          return false;
        });
      });

      // Feedback visual
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meta removida com sucesso!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Exibe diálogo de confirmação de remoção (reutilizável)
  Future<bool?> _showRemoveConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Só fecha pelos botões
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Remoção'),
        content: const Text(
          'Tem certeza que deseja remover esta meta? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTypeChip(String goalType) {
    final colors = _getGoalTypeColor(goalType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        goalType.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: colors['text'],
        ),
      ),
    );
  }

  Map<String, Color> _getGoalTypeColor(String goalType) {
    switch (goalType) {
      case 'mood_entries':
        return {'bg': Colors.purple.shade100, 'text': Colors.purple.shade800};
      case 'meditation_minutes':
        return {'bg': Colors.blue.shade100, 'text': Colors.blue.shade800};
      case 'water_glasses':
        return {'bg': Colors.cyan.shade100, 'text': Colors.cyan.shade800};
      case 'exercise_minutes':
        return {'bg': Colors.orange.shade100, 'text': Colors.orange.shade800};
      case 'sleep_hours':
        return {'bg': Colors.indigo.shade100, 'text': Colors.indigo.shade800};
      default:
        return {'bg': Colors.grey.shade100, 'text': Colors.grey.shade800};
    }
  }

  String _getGoalTypeLabel(String goalType) {
    switch (goalType) {
      case 'mood_entries':
        return 'Registros de Humor';
      case 'meditation_minutes':
        return 'Minutos de Meditação';
      case 'water_glasses':
        return 'Copos de Água';
      case 'exercise_minutes':
        return 'Minutos de Exercício';
      case 'sleep_hours':
        return 'Horas de Sono';
      default:
        return goalType.replaceAll('_', ' ');
    }
  }
}
