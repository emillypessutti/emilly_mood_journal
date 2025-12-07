// Interface de repositório para a entidade MoodStatisticsEntity.
// Estatísticas são derivadas: podem vir de agregação local ou endpoint remoto.
// Repositório oferece ponto único para obter snapshots consolidados por período.

import '../../../../domain/entities/mood_statistics_entity.dart';

abstract class MoodStatisticsRepository {
  // Carrega estatísticas previamente calculadas (cache) para exibição imediata.
  /// Retorna estatísticas armazenadas localmente (sem garantir frescor).
  Future<List<MoodStatisticsEntity>> loadFromCache();

  // Sincroniza agregados recalculando ou buscando do servidor; retorna quantos snapshots mudaram.
  /// Executa sync de estatísticas e informa quantidade de registros alterados.
  Future<int> syncFromServer();

  // Lista completa de snapshots disponíveis (ex.: dias recentes, semanas, meses).
  /// Retorna todos os snapshots consolidados.
  Future<List<MoodStatisticsEntity>> listAll();

  // Destaques: períodos com melhor média ou picos diversos.
  /// Retorna estatísticas destacadas (ex.: maiores médias de humor).
  Future<List<MoodStatisticsEntity>> listFeatured();

  // Busca direta por ID interno (se existir) ou índice posicional em implementação local.
  /// Retorna uma estatística específica por ID ou null se não encontrada.
  Future<MoodStatisticsEntity?> getById(int id);
}

/*
// Exemplo de uso:
// final repo = MoodStatisticsRepositoryImpl(localAgg, remoteAgg);
// final cacheStats = await repo.loadFromCache();
// await repo.syncFromServer();
// final todas = await repo.listAll();
// final top = await repo.listFeatured();
// final stat = await repo.getById(3);
//
// Dicas:
// - Armazene hashes de distribuição para detectar mudanças.
// - Utilize chave composta (userId + period + startDate) como ID lógico.
// - Em sync local, recalcular apenas janelas afetadas (incremental aggregation).
// - Cuidado com timezone: normalizar para UTC evitando desvios em períodos.
*/
