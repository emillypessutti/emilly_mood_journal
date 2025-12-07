import 'package:flutter/foundation.dart';
import '../../domain/entities/mood_entry_entity.dart';
import '../../features/mood_entries/domain/repositories/mood_entry_repository.dart';
import '../datasources/local/mood_entry_local_datasource.dart';
import '../datasources/remote/mood_entry_remote_datasource.dart';
import '../../services/supabase_service.dart';

/// Implementação concreta do repositório MoodEntry
/// Combina cache local (SharedPreferences) + sync remoto (Supabase)
class MoodEntryRepositoryImpl implements MoodEntriesRepository {
  final MoodEntryLocalDataSource _local;
  final MoodEntryRemoteDataSource _remote;

  MoodEntryRepositoryImpl(this._local, this._remote);

  @override
  Future<List<MoodEntryEntity>> loadFromCache() async {
    if (kDebugMode) print('[MoodEntryRepo] loadFromCache');
    return await _local.getAll();
  }

  @override
  Future<int> syncFromServer() async {
    if (!SupabaseService.isInitialized) {
      if (kDebugMode) print('[MoodEntryRepo] Supabase não inicializado, skip sync');
      return 0;
    }

    try {
      final lastSync = await _local.getLastSync() ?? DateTime(2020);
      if (kDebugMode) print('[MoodEntryRepo] syncFromServer desde $lastSync');
      
      final remote = await _remote.syncMoodEntriesSince(lastSync);
      if (kDebugMode) print('[MoodEntryRepo] baixou ${remote.length} registros');

      // Merge: sobrescreve local com remoto por ID
      final localMap = {for (var e in await _local.getAll()) e.id: e};
      for (var r in remote) {
        localMap[r.id] = r;
      }
      
      await _local.saveAll(localMap.values.toList());
      await _local.setLastSync(DateTime.now());
      
      if (kDebugMode) print('[MoodEntryRepo] sync completo, total=${localMap.length}');
      return remote.length;
    } catch (e) {
      if (kDebugMode) print('[MoodEntryRepo] Erro sync: $e');
      return 0;
    }
  }

  @override
  Future<List<MoodEntryEntity>> listAll() async {
    return await loadFromCache();
  }

  @override
  Future<List<MoodEntryEntity>> listFeatured() async {
    final all = await listAll();
    // Critério: nível >= 4 (happy ou veryHappy)
    return all.where((e) => e.level.value >= 4).toList();
  }

  @override
  Future<MoodEntryEntity?> getById(int id) async {
    return await _local.getById(id.toString());
  }

  // Métodos extras para CRUD completo
  Future<void> add(MoodEntryEntity entry) async {
    await _local.insert(entry);
    
    if (SupabaseService.isInitialized && SupabaseService.currentUser != null) {
      try {
        await _remote.syncMoodEntriesSince(DateTime.now().subtract(const Duration(seconds: 1)));
      } catch (e) {
        if (kDebugMode) print('[MoodEntryRepo] Erro push novo: $e');
      }
    }
  }

  Future<void> remove(String id) async {
    await _local.delete(id);
  }
}
