import 'package:flutter/material.dart';

enum EntityDetailAction { fechar, editar, remover }

Future<EntityDetailAction?> showEntityDetailDialog(
  BuildContext context, {
  required String title,
  String? description,
  Widget? details,
}) {
  return showDialog<EntityDetailAction>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(title),
        content: details ??
            (description != null ? Text(description) : const SizedBox.shrink()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(EntityDetailAction.fechar),
            child: const Text('FECHAR'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(EntityDetailAction.editar),
            child: const Text('EDITAR'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(EntityDetailAction.remover),
            child: const Text('REMOVER'),
          ),
        ],
      );
    },
  );
}
