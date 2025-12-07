// Interface de repositório para a entidade DailyGoalEntity.
// Foco em metas diárias: combina estado efêmero (hoje) com histórico.
// Recomenda-se invalidar cache ao virar o dia.

import '../../../../domain/entities/daily_goal_entity.dart';

abstract class DailyGoalsRepository {
  // Carrega metas recentes do cache para evitar tela vazia ao abrir.
  /// Retorna metas do cache local (pode incluir dias recentes).
  Future<List<DailyGoalEntity>> loadFromCache();

  // Sincroniza metas novas/atualizadas (ex.: progresso alterado em outro dispositivo).
  /// Atualiza cache a partir do servidor e retorna quantidade de metas modificadas.
  Future<int> syncFromServer();

  // Lista completa (possível limitar internamente a X dias para performance).
  /// Retorna todas as metas disponíveis conforme política interna.
  Future<List<DailyGoalEntity>> listAll();

  // Destaques: metas concluídas ou priorizadas.
  /// Retorna metas destacadas (ex.: concluídas ou com progresso > 80%).
  Future<List<DailyGoalEntity>> listFeatured();

  // Busca por ID (útil em telas de detalhe ou edição).
  /// Obtém meta pelo ID no cache ou null se não existir.
  Future<DailyGoalEntity?> getById(int id);
}

/*
// Exemplo de uso:
// final repo = DailyGoalsRepositoryImpl(local, remote);
// final cacheHoje = await repo.loadFromCache();
// final mudou = await repo.syncFromServer();
// final metas = await repo.listAll();
// final destaques = await repo.listFeatured();
// final meta = await repo.getById(7);
//
// Boas práticas:
// - Normalizar date (zerar hora) para comparar corretamente.
// - Prevenir duplicados usando chave composta (userId+date+type) no cache.
// - Em sync, marcar metas expiradas para arquivamento se necessário.
// - Considerar pré-cálculo de progresso agregado para relatórios.
*/
