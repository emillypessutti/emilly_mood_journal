// Interface de repositório para a entidade UserProfileEntity.
//
// O repositório abstrai o acesso a dados (cache local, fonte remota, etc.)
// separando persistência da lógica de negócio. Isso facilita testes (mock/fake)
// e futuras trocas de implementação (ex.: trocar SharedPreferences por SQLite ou Supabase).
//
// ⚠️ Boas práticas:
// - Mantenha cada implementação pequena e focada (ex.: LocalUserProfileDataSource, RemoteUserProfileDataSource).
// - Use logs (kDebugMode) durante o desenvolvimento para inspecionar tamanhos de listas e tempos de sync.
// - Evite que a UI dependa de detalhes de infraestrutura (nunca expor SupabaseClient aqui).
// - Trate diferenças de schema no mapeamento DTO ↔ Entity.
// - Garanta que IDs sejam estáveis para merges durante sync.
//
// Ao implementar, considere estratégias de cache: carregamento inicial rápido via loadFromCache
// seguido de syncFromServer para atualizar os dados em background.

import '../../../../domain/entities/user_profile_entity.dart';

abstract class UserProfilesRepository {
  // Render inicial rápido a partir do cache local para uma UI responsiva.
  /// Retorna perfis presentes no cache local (sem garantir frescor).
  Future<List<UserProfileEntity>> loadFromCache();

  // Sincronização incremental com fonte remota (>= lastSync). Atualiza cache e retorna quantos registros mudaram.
  /// Executa sync incremental e devolve quantidade de registros modificados.
  Future<int> syncFromServer();

  // Listagem completa geralmente após sync; unified view do cache atualizado.
  /// Lista todos os perfis disponíveis (fonte principal após sync). 
  Future<List<UserProfileEntity>> listAll();

  // Destaques: perfis marcados como featured (critério definido pela implementação).
  /// Lista perfis destacados (ex.: favoritos, mais usados).
  Future<List<UserProfileEntity>> listFeatured();

  // Acesso direto por ID para otimizar detalhes sem varrer lista inteira.
  /// Busca um perfil por ID no cache; retorna null se não encontrado.
  Future<UserProfileEntity?> getById(int id);
}

/*
// Exemplo de uso:
// final repo = UserProfilesRepositoryImpl(localDs, remoteDs);
// final cache = await repo.loadFromCache();
// await repo.syncFromServer();
// final todos = await repo.listAll();
// final destaque = await repo.listFeatured();
// final perfil = await repo.getById(123);
//
// Dicas de implementação:
// - Mantenha lastSync em uma chave de metadados (ex.: SharedPreferences).
// - Na sync, aplique merge por ID. Use transações se for SQLite.
// - Em ambientes com Supabase, trate RLS e erros de rede com retries exponenciais simples.
// - Para testes, faça um FakeUserProfilesRepository retornando dados estáticos.
// - Log comum para diagnóstico: print('[UserProfilesRepository] sync changed=$changedCount total=${todos.length}');
//
// Checklist de erros comuns:
// - IDs inconsistentes: normalize antes de salvar.
// - Falha de conversão de datas: garanta uso consistente de UTC ou local.
// - UI não atualiza após sync: confirme que provider notifica listeners (ex.: ref.invalidate/cacheProvider).
*/
