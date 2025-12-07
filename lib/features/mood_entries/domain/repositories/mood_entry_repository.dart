// Interface de repositório para a entidade MoodEntryEntity.
// Ver comentários gerais no arquivo similar de UserProfiles para princípios de arquitetura.
// Esta interface foca em performance de listagem e atualização incremental.
//
// Estratégia recomendada: carregar lista local rapidamente (loadFromCache),
// disparar syncFromServer em segundo plano, atualizar providers quando completo.

import '../../../../domain/entities/mood_entry_entity.dart';

abstract class MoodEntriesRepository {
  // Carregamento inicial rápido para preencher a UI imediatamente.
  /// Retorna registros de humor do cache local sem garantir atualização.
  Future<List<MoodEntryEntity>> loadFromCache();

  // Sincroniza apenas alterações desde o último sync (minimiza tráfego).
  /// Executa sync incremental e retorna quantidade de registros alterados.
  Future<int> syncFromServer();

  // Lista completa consolidada (após sync idealmente) usada para gráficos/estatísticas.
  /// Retorna todos os registros consolidados disponíveis.
  Future<List<MoodEntryEntity>> listAll();

  // Destaques: registros marcados; critério pode ser nível alto ou tag especial.
  /// Retorna registros destacados (ex.: nível muito feliz, tag 'gratitude').
  Future<List<MoodEntryEntity>> listFeatured();

  // Busca direta por ID para detalhes/edição rápida.
  /// Obtém um registro específico por ID no cache ou null se ausente.
  Future<MoodEntryEntity?> getById(int id);
}

/*
// Exemplo de uso:
// final repo = MoodEntriesRepositoryImpl(local, remote);
// final inicial = await repo.loadFromCache();
// final alterados = await repo.syncFromServer();
// final todos = await repo.listAll();
// final destaque = await repo.listFeatured();
// final registro = await repo.getById(42);
//
// Boas práticas específicas:
// - Indexe por timestamp para filtros de período.
// - Armazene tags normalizadas (lowercase) para facilitar busca.
// - Em sync, resolver conflitos por timestamp mais recente.
// - Otimize listFeatured usando consulta pré-computada ou índice.
*/
