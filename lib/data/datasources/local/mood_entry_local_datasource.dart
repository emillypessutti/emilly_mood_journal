import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/mood_entry_entity.dart';

/// DataSource local para MoodEntry usando SharedPreferences
class MoodEntryLocalDataSource {
  final SharedPreferences _prefs;
  static const _keyEntries = 'mood_entries_cache';
  static const _keyLastSync = 'mood_entries_last_sync';

  MoodEntryLocalDataSource(this._prefs);

  Future<List<MoodEntryEntity>> getAll() async {
    final jsonStr = _prefs.getString(_keyEntries);
    if (jsonStr == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((item) => _fromMap(item as Map<String, dynamic>)).toList();
  }

  Future<void> saveAll(List<MoodEntryEntity> entries) async {
    final jsonList = entries.map(_toMap).toList();
    await _prefs.setString(_keyEntries, json.encode(jsonList));
  }

  Future<MoodEntryEntity?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> insert(MoodEntryEntity entry) async {
    final all = await getAll();
    all.add(entry);
    await saveAll(all);
  }

  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((e) => e.id == id);
    await saveAll(all);
  }

  Future<DateTime?> getLastSync() async {
    final ts = _prefs.getString(_keyLastSync);
    return ts != null ? DateTime.parse(ts) : null;
  }

  Future<void> setLastSync(DateTime dt) async {
    await _prefs.setString(_keyLastSync, dt.toIso8601String());
  }

  Map<String, dynamic> _toMap(MoodEntryEntity e) => {
    'id': e.id,
    'level': e.level.value,
    'timestamp': e.timestamp.toIso8601String(),
    'note': e.note,
    'tags': e.tags,
  };

  MoodEntryEntity _fromMap(Map<String, dynamic> m) => MoodEntryEntity(
    id: m['id'] as String,
    level: MoodLevel.fromValue(m['level'] as int),
    timestamp: DateTime.parse(m['timestamp'] as String),
    note: m['note'] as String?,
    tags: (m['tags'] as List?)?.cast<String>(),
  );
}
