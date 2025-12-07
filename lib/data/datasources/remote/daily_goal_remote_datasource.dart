import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase_service.dart';
import '../../../domain/entities/daily_goal_entity.dart';

/// DataSource remoto (Supabase) para sincronização de Daily Goals
class DailyGoalRemoteDataSource {
  final SupabaseClient _client = SupabaseService.client;

  /// Retorna metas alteradas/criadas desde o timestamp. Como não há campo updated_at,
  /// usa a data (date) >= dia do since para simplificar.
  Future<List<DailyGoalEntity>> syncDailyGoalsSince(DateTime since) async {
    final sinceDate = DateTime(since.year, since.month, since.day).toIso8601String();
    final data = await _client
        .from('daily_goals')
        .select()
        .gte('date', sinceDate)
        .order('date');

    return (data as List).map((row) {
      return DailyGoalEntity(
        id: row['id'] as String,
        userId: row['user_id'] as String,
        type: GoalType.fromString(row['type'] as String),
        targetValue: row['target_value'] as int,
        currentValue: row['current_value'] as int,
        date: DateTime.parse(row['date'] as String),
        isCompleted: row['is_completed'] as bool,
      );
    }).toList();
  }
}
