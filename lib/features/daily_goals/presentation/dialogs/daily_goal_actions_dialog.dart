// Diálogo de ações para DailyGoalEntity (Editar, Remover, Fechar)
import 'package:flutter/material.dart';

/// Ações disponíveis no diálogo de seleção de meta
enum DailyGoalAction {
  edit,
  remove,
  close,
}

/// Exibe um diálogo com opções de ação para uma meta diária selecionada.
/// 
/// Retorna [DailyGoalAction] correspondente à ação escolhida pelo usuário,
/// ou `null` se nenhuma ação for selecionada (não deve ocorrer pois barrierDismissible: false).
Future<DailyGoalAction?> showDailyGoalActionsDialog(BuildContext context) {
  return showDialog<DailyGoalAction>(
    context: context,
    barrierDismissible: false, // Só fecha pelos botões internos
    builder: (ctx) => const _DailyGoalActionsDialog(),
  );
}

class _DailyGoalActionsDialog extends StatelessWidget {
  const _DailyGoalActionsDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'O que deseja fazer?',
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botão Editar
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(DailyGoalAction.edit),
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          
          // Botão Remover
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(DailyGoalAction.remove),
            icon: const Icon(Icons.delete),
            label: const Text('Remover'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          
          // Botão Fechar
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(DailyGoalAction.close),
            icon: const Icon(Icons.close),
            label: const Text('Fechar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
