import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/daily_goal_entity.dart';
import '../../data/datasources/local/daily_goal_local_datasource.dart';
import '../../data/datasources/remote/daily_goal_remote_datasource.dart';
import '../../data/repositories/daily_goal_repository_impl.dart';
import '../../features/daily_goals/domain/repositories/daily_goal_repository.dart';
import '../../di/injection_container.dart';

final dailyGoalRepositoryProvider = Provider<DailyGoalsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final local = DailyGoalLocalDataSource(prefs);
  final remote = DailyGoalRemoteDataSource();
  return DailyGoalRepositoryImpl(local, remote);
});

final dailyGoalsListProvider = FutureProvider<List<DailyGoalEntity>>((ref) async {
  final repo = ref.watch(dailyGoalRepositoryProvider);
  return await repo.loadFromCache();
});

class DailyGoalsNotifier extends StateNotifier<AsyncValue<List<DailyGoalEntity>>> {
  final DailyGoalsRepository _repo;

  DailyGoalsNotifier(this._repo) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    state = const AsyncValue.loading();
    try {
      final goals = await _repo.loadFromCache();
      state = AsyncValue.data(goals);
      
      _repo.syncFromServer().then((_) async {
        final updated = await _repo.listAll();
        state = AsyncValue.data(updated);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _init();
  }

  Future<void> saveGoal(DailyGoalEntity goal) async {
    final repo = _repo as DailyGoalRepositoryImpl;
    await repo.save(goal);
    await refresh();
  }
}

final dailyGoalsNotifierProvider = StateNotifierProvider<DailyGoalsNotifier, AsyncValue<List<DailyGoalEntity>>>((ref) {
  final repo = ref.watch(dailyGoalRepositoryProvider);
  return DailyGoalsNotifier(repo);
});
