// Gerado: Dialog de inserção/edição para DailyGoalEntity
// Ajuste o import/tipo se necessário. Este arquivo pressupõe que
// `DailyGoalEntity` e `GoalType` estão definidos em:
// `package:mood_journal/domain/entities/daily_goal_entity.dart`

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/daily_goal_entity.dart';

/// Abre uma dialog para criar/editar uma DailyGoalEntity.
///
/// Retorna a instância preenchida ou `null` se cancelado.
Future<DailyGoalEntity?> showDailyGoalEntityFormDialog(
  BuildContext context, {
  DailyGoalEntity? initial,
  String? userId,
}) {
  return showDialog<DailyGoalEntity>(
    context: context,
    builder: (ctx) => _DailyGoalEntityFormDialog(initial: initial, userId: userId),
  );
}

class _DailyGoalEntityFormDialog extends StatefulWidget {
  const _DailyGoalEntityFormDialog({this.initial, this.userId});
  final DailyGoalEntity? initial;
  final String? userId;

  @override
  State<_DailyGoalEntityFormDialog> createState() =>
      _DailyGoalEntityFormDialogState();
}

class _DailyGoalEntityFormDialogState
    extends State<_DailyGoalEntityFormDialog> {
  // ID e UserID serão gerados automaticamente; não expor no formulário
  late final TextEditingController _idController;
  late final TextEditingController _userIdController;
  GoalType? _selectedType;
  late final TextEditingController _targetValueController;
  late final TextEditingController _currentValueController;
  DateTime? _selectedDate;
  bool _isCompleted = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _idController = TextEditingController(text: initial?.id ?? _generateId());
    _userIdController = TextEditingController(text: initial?.userId ?? (widget.userId ?? _resolveUserId()));
    _selectedType = initial?.type ?? GoalType.moodEntries;
    _targetValueController =
        TextEditingController(text: initial?.targetValue.toString() ?? '');
    _currentValueController =
        TextEditingController(text: initial?.currentValue.toString() ?? '');
    _selectedDate = initial?.date ?? DateTime.now();
    _isCompleted = initial?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _idController.dispose();
    _userIdController.dispose();
    _targetValueController.dispose();
    _currentValueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat.yMMMd().format(date);
    } catch (_) {
      return date.toIso8601String();
    }
  }

  void _onConfirm() {
    // Validação mínima conforme especificado:
    // ID e User ID são gerados automaticamente quando faltam
    if (_idController.text.trim().isEmpty) {
      _idController.text = _generateId();
    }
    if (_userIdController.text.trim().isEmpty) {
      _userIdController.text = _resolveUserId();
    }
    if (_selectedType == null) {
      _showError('Tipo de meta é obrigatório.');
      return;
    }
    final targetText = _targetValueController.text.trim();
    final currentText = _currentValueController.text.trim();
    // Se não preenchidos, aplicar valores padrão
    final targetValue = int.tryParse(targetText) ?? _defaultTargetFor(_selectedType);
    final currentValue = int.tryParse(currentText) ?? 0;

    if (targetValue <= 0) {
      _showError('Valor alvo deve ser um número inteiro maior que 0.');
      return;
    }
    if (currentValue < 0) {
      _showError('Valor atual deve ser um inteiro >= 0.');
      return;
    }

    final date = _selectedDate ?? DateTime.now();

    final dto = DailyGoalEntity(
      id: _idController.text.trim(),
      userId: _userIdController.text.trim(),
      type: _selectedType!,
      targetValue: targetValue,
      currentValue: currentValue,
      date: date,
      isCompleted: _isCompleted,
    );

    Navigator.of(context).pop(dto);
  }

  // Gera um ID simples sem dependências (timestamp)
  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  // Resolve o userId automaticamente; aqui usamos um placeholder.
  // Opcional: integrar com provider de perfil para usar o ID real do usuário.
  String _resolveUserId() => 'user1';

  // Define um alvo padrão baseado no tipo de meta
  int _defaultTargetFor(GoalType? type) {
    switch (type) {
      case GoalType.moodEntries:
        return 1; // 1 registro por dia
      case GoalType.positiveEntries:
        return 1; // 1 registro positivo por dia
      case GoalType.reflection:
        return 10; // 10 minutos de reflexão
      case GoalType.gratitude:
        return 3; // 3 itens de gratidão
      default:
        return 1;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    return AlertDialog(
      title: Text(isEditing ? 'Editar Meta Diária' : 'Adicionar Meta Diária'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Removido do formulário: ID e User ID (gerados automaticamente)
              const SizedBox(height: 0),
              // Tipo (enum)
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Tipo de meta'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<GoalType>(
                    value: _selectedType,
                    isExpanded: true,
                    items: GoalType.values
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text('${g.icon} ${g.description}'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedType = v),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Valor alvo (opcional)
              TextFormField(
                controller: _targetValueController,
                decoration: const InputDecoration(
                  labelText: 'Valor alvo (opcional)',
                  helperText:
                      'Ex.: 8 copos de água, 30 min de exercício. Se vazio, usamos um padrão para o tipo escolhido.',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              // Valor atual (opcional)
              TextFormField(
                controller: _currentValueController,
                decoration: const InputDecoration(
                  labelText: 'Valor atual (opcional)',
                  helperText:
                      'Quanto já foi cumprido hoje. Se vazio, começa em 0.',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              // Date picker
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Data'),
                      child: Text(
                        _selectedDate != null
                            ? _formatDate(_selectedDate!)
                            : 'Selecionar data',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Escolher'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // isCompleted
              Row(
                children: [
                  const Expanded(child: Text('Concluída?')),
                  Switch(
                    value: _isCompleted,
                    onChanged: (v) => setState(() => _isCompleted = v),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _onConfirm,
          child: Text(isEditing ? 'Salvar' : 'Adicionar'),
        ),
      ],
    );
  }
}
