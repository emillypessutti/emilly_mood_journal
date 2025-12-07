import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mood_entry_entity.dart';
import '../../data/datasources/local/mood_entry_local_datasource.dart';
import '../../data/datasources/remote/mood_entry_remote_datasource.dart';
import '../../data/repositories/mood_entry_repository_impl.dart';
import '../../features/mood_entries/domain/repositories/mood_entry_repository.dart';
import '../../di/injection_container.dart';

/// Provider do repositório MoodEntry
final moodEntryRepositoryProvider = Provider<MoodEntriesRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final local = MoodEntryLocalDataSource(prefs);
  final remote = MoodEntryRemoteDataSource();
  return MoodEntryRepositoryImpl(local, remote);
});

/// Provider para lista de entradas (cache)
final moodEntriesListProvider = FutureProvider<List<MoodEntryEntity>>((ref) async {
  final repo = ref.watch(moodEntryRepositoryProvider);
  return await repo.loadFromCache();
});

/// StateNotifier para gerenciar estado de mood entries
class MoodEntriesNotifier extends StateNotifier<AsyncValue<List<MoodEntryEntity>>> {
  final MoodEntriesRepository _repo;

  MoodEntriesNotifier(this._repo) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    state = const AsyncValue.loading();
    try {
      final entries = await _repo.loadFromCache();
      state = AsyncValue.data(entries);
      
      // Sync em background
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

  Future<void> addEntry(MoodEntryEntity entry) async {
    final repo = _repo as MoodEntryRepositoryImpl;
    await repo.add(entry);
    await refresh();
  }

  Future<void> deleteEntry(String id) async {
    final repo = _repo as MoodEntryRepositoryImpl;
    await repo.remove(id);
    await refresh();
  }
}

final moodEntriesNotifierProvider = StateNotifierProvider<MoodEntriesNotifier, AsyncValue<List<MoodEntryEntity>>>((ref) {
  final repo = ref.watch(moodEntryRepositoryProvider);
  return MoodEntriesNotifier(repo);
});
