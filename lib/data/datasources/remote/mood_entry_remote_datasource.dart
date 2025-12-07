import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase_service.dart';
import '../../../domain/entities/mood_entry_entity.dart';

/// DataSource remoto (Supabase) para sincronização de Mood Entries
class MoodEntryRemoteDataSource {
  final SupabaseClient _client = SupabaseService.client;

  /// Retorna registros modificados/criados desde o timestamp informado
  Future<List<MoodEntryEntity>> syncMoodEntriesSince(DateTime since) async {
    final data = await _client
        .from('mood_entries')
        .select()
        .gte('timestamp', since.toIso8601String())
        .order('timestamp');

    return (data as List).map((row) {
      return MoodEntryEntity(
        id: row['id'] as String,
        level: MoodLevel.fromValue(row['level'] as int),
        timestamp: DateTime.parse(row['timestamp'] as String),
        note: row['note'] as String?,
        tags: (row['tags'] as List?)?.cast<String>(),
      );
    }).toList();
  }
}
