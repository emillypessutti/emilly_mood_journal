import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/daily_goal_entity.dart';

class DailyGoalLocalDataSource {
  final SharedPreferences _prefs;
  static const _keyGoals = 'daily_goals_cache';
  static const _keyLastSync = 'daily_goals_last_sync';

  DailyGoalLocalDataSource(this._prefs);

  Future<List<DailyGoalEntity>> getAll() async {
    final jsonStr = _prefs.getString(_keyGoals);
    if (jsonStr == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((item) => _fromMap(item as Map<String, dynamic>)).toList();
  }

  Future<void> saveAll(List<DailyGoalEntity> goals) async {
    final jsonList = goals.map(_toMap).toList();
    await _prefs.setString(_keyGoals, json.encode(jsonList));
  }

  Future<DailyGoalEntity?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert(DailyGoalEntity goal) async {
    final all = await getAll();
    final index = all.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      all[index] = goal;
    } else {
      all.add(goal);
    }
    await saveAll(all);
  }

  Future<DateTime?> getLastSync() async {
    final ts = _prefs.getString(_keyLastSync);
    return ts != null ? DateTime.parse(ts) : null;
  }

  Future<void> setLastSync(DateTime dt) async {
    await _prefs.setString(_keyLastSync, dt.toIso8601String());
  }

  Map<String, dynamic> _toMap(DailyGoalEntity g) => {
    'id': g.id,
    'userId': g.userId,
    'type': g.type.name,
    'targetValue': g.targetValue,
    'currentValue': g.currentValue,
    'date': g.date.toIso8601String(),
    'isCompleted': g.isCompleted,
  };

  DailyGoalEntity _fromMap(Map<String, dynamic> m) => DailyGoalEntity(
    id: m['id'] as String,
    userId: m['userId'] as String,
    type: GoalType.fromString(m['type'] as String),
    targetValue: m['targetValue'] as int,
    currentValue: m['currentValue'] as int,
    date: DateTime.parse(m['date'] as String),
    isCompleted: m['isCompleted'] as bool,
  );
}
