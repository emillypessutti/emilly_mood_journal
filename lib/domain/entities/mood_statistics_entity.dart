/// Entity de domínio para estatísticas de humor agregadas
/// Representa métricas calculadas para um período (dia, semana, mês, custom)
class MoodStatisticsEntity {
  MoodStatisticsEntity({
    required this.userId,
    required this.period,
    required this.averageMood,
    required this.totalEntries,
    required Map<String, int> moodDistribution,
    required this.startDate,
    required this.endDate,
  })  : moodDistribution = Map.unmodifiable(moodDistribution),
        assert(userId.isNotEmpty, 'userId não pode ser vazio'),
        assert(totalEntries >= 0, 'totalEntries deve ser >= 0'),
        assert(averageMood >= 1 && averageMood <= 5,
            'averageMood deve estar entre 1 e 5'),
        assert(!endDate.isBefore(startDate), 'endDate não pode ser antes de startDate');

  final String userId;
  final Period period;
  final double averageMood; // média ponderada dos níveis de humor (1..5)
  final int totalEntries; // quantidade total de registros no período
  final Map<String, int> moodDistribution; // chave = nível (ex: 'veryHappy'), valor = contagem
  final DateTime startDate;
  final DateTime endDate;

  int get distinctLevels => moodDistribution.length;
  bool get isEmpty => totalEntries == 0;
  Duration get duration => endDate.difference(startDate);

  MoodStatisticsEntity copyWith({
    String? userId,
    Period? period,
    double? averageMood,
    int? totalEntries,
    Map<String, int>? moodDistribution,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return MoodStatisticsEntity(
      userId: userId ?? this.userId,
      period: period ?? this.period,
      averageMood: averageMood ?? this.averageMood,
      totalEntries: totalEntries ?? this.totalEntries,
      moodDistribution: moodDistribution ?? this.moodDistribution,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  String toString() {
    return 'MoodStatisticsEntity(userId: $userId, period: ${period.name}, avg: $averageMood, total: $totalEntries)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodStatisticsEntity &&
        other.userId == userId &&
        other.period == period &&
        other.averageMood == averageMood &&
        other.totalEntries == totalEntries &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode =>
      userId.hashCode ^
      period.hashCode ^
      averageMood.hashCode ^
      totalEntries.hashCode ^
      startDate.hashCode ^
      endDate.hashCode;
}

/// Enum representando o tipo de período de agregação
enum Period {
  day,
  week,
  month,
  custom;

  static Period fromString(String value) {
    return Period.values.firstWhere(
      (p) => p.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Periodo inválido: $value'),
    );
  }
}
