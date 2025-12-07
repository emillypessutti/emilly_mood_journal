import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';
import 'supabase_service.dart';
import '../data/datasources/remote/mood_entry_remote_datasource.dart';
import '../data/datasources/remote/daily_goal_remote_datasource.dart';

/// Serviço de sincronização entre cache local (SharedPreferences) e Supabase
class SyncService {
  final ConnectivityService _connectivityService = ConnectivityService();
  final MoodEntryRemoteDataSource _moodEntryRemote = MoodEntryRemoteDataSource();
  final DailyGoalRemoteDataSource _dailyGoalRemote = DailyGoalRemoteDataSource();

  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _pendingChangesKey = 'pending_changes';

  /// Verifica se há alterações pendentes para sincronizar
  Future<bool> hasPendingChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingChanges = prefs.getStringList(_pendingChangesKey) ?? [];
    return pendingChanges.isNotEmpty;
  }

  /// Adiciona uma mudança pendente para sincronização
  Future<void> addPendingChange(String changeId) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingChanges = prefs.getStringList(_pendingChangesKey) ?? [];
    if (!pendingChanges.contains(changeId)) {
      pendingChanges.add(changeId);
      await prefs.setStringList(_pendingChangesKey, pendingChanges);
    }
  }

  /// Remove uma mudança pendente da fila
  Future<void> removePendingChange(String changeId) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingChanges = prefs.getStringList(_pendingChangesKey) ?? [];
    pendingChanges.remove(changeId);
    await prefs.setStringList(_pendingChangesKey, pendingChanges);
  }

  /// Obtém a data da última sincronização
  Future<DateTime?> getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.parse(timestamp);
  }

  /// Atualiza a data da última sincronização
  Future<void> updateLastSyncTimestamp(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, timestamp.toIso8601String());
  }

  /// Sincroniza todos os dados com o Supabase
  Future<SyncResult> syncAll() async {
    if (!SupabaseService.isInitialized) {
      return SyncResult(
        success: false,
        message: 'Supabase não inicializado',
        syncedCount: 0,
      );
    }

    final hasConnection = await _connectivityService.hasInternetConnection();
    if (!hasConnection) {
      return SyncResult(
        success: false,
        message: 'Sem conexão com a internet',
        syncedCount: 0,
      );
    }

    try {
      int syncedCount = 0;
      final lastSync = await getLastSyncTimestamp();

      // Sincroniza mood entries
      if (lastSync != null) {
        final moodEntries = await _moodEntryRemote.syncMoodEntriesSince(lastSync);
        syncedCount += moodEntries.length;
      }

      // Sincroniza daily goals
      if (lastSync != null) {
        final dailyGoals = await _dailyGoalRemote.syncDailyGoalsSince(lastSync);
        syncedCount += dailyGoals.length;
      }

      // Atualiza timestamp
      await updateLastSyncTimestamp(DateTime.now());

      // Limpa mudanças pendentes
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingChangesKey);

      return SyncResult(
        success: true,
        message: 'Sincronização concluída',
        syncedCount: syncedCount,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Erro na sincronização: $e',
        syncedCount: 0,
      );
    }
  }

  /// Sincroniza apenas se houver conexão e mudanças pendentes
  Future<SyncResult> syncIfNeeded() async {
    if (!SupabaseService.isInitialized) {
      return SyncResult(
        success: false,
        message: 'Supabase não inicializado',
        syncedCount: 0,
      );
    }

    final hasConnection = await _connectivityService.hasInternetConnection();
    if (!hasConnection) {
      return SyncResult(
        success: false,
        message: 'Aguardando conexão',
        syncedCount: 0,
      );
    }

    final hasPending = await hasPendingChanges();
    if (!hasPending) {
      return SyncResult(
        success: true,
        message: 'Nenhuma mudança pendente',
        syncedCount: 0,
      );
    }

    return syncAll();
  }

  /// Monitora conectividade e sincroniza automaticamente quando ficar online
  Stream<SyncResult> autoSync() async* {
    await for (final _ in _connectivityService.onConnectivityChanged) {
      // Aguarda um pouco para garantir que a conexão está estável
      await Future.delayed(const Duration(seconds: 2));

      final hasConnection = await _connectivityService.hasInternetConnection();
      if (hasConnection) {
        yield await syncIfNeeded();
      }
    }
  }
}

/// Resultado de uma operação de sincronização
class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, message: $message, syncedCount: $syncedCount)';
  }
}
