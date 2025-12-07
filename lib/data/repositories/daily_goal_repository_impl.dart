import 'package:flutter/foundation.dart';
import '../../domain/entities/daily_goal_entity.dart';
import '../../features/daily_goals/domain/repositories/daily_goal_repository.dart';
import '../datasources/local/daily_goal_local_datasource.dart';
import '../datasources/remote/daily_goal_remote_datasource.dart';
import '../../services/supabase_service.dart';

class DailyGoalRepositoryImpl implements DailyGoalsRepository {
  final DailyGoalLocalDataSource _local;
  final DailyGoalRemoteDataSource _remote;

  DailyGoalRepositoryImpl(this._local, this._remote);

  @override
  Future<List<DailyGoalEntity>> loadFromCache() async {
    if (kDebugMode) print('[DailyGoalRepo] loadFromCache');
    return await _local.getAll();
  }

  @override
  Future<int> syncFromServer() async {
    if (!SupabaseService.isInitialized) {
      if (kDebugMode) print('[DailyGoalRepo] Supabase não inicializado');
      return 0;
    }

    try {
      final lastSync = await _local.getLastSync() ?? DateTime(2020);
      if (kDebugMode) print('[DailyGoalRepo] sync desde $lastSync');
      
      final remote = await _remote.syncDailyGoalsSince(lastSync);
      if (kDebugMode) print('[DailyGoalRepo] baixou ${remote.length} metas');

      final localMap = {for (var g in await _local.getAll()) g.id: g};
      for (var r in remote) {
        localMap[r.id] = r;
      }
      
      await _local.saveAll(localMap.values.toList());
      await _local.setLastSync(DateTime.now());
      
      return remote.length;
    } catch (e) {
      if (kDebugMode) print('[DailyGoalRepo] Erro sync: $e');
      return 0;
    }
  }

  @override
  Future<List<DailyGoalEntity>> listAll() async {
    return await loadFromCache();
  }

  @override
  Future<List<DailyGoalEntity>> listFeatured() async {
    final all = await listAll();
    return all.where((g) => g.isCompleted || g.progressPercentage >= 80).toList();
  }

  @override
  Future<DailyGoalEntity?> getById(int id) async {
    return await _local.getById(id.toString());
  }

  Future<void> save(DailyGoalEntity goal) async {
    await _local.upsert(goal);
  }
}
