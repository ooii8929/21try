// Bear Habit Distance Mechanism - State Model
class BearState {
  final DateTime? lastCheckinLocalDate;
  final int baseDistance;
  final int lastShownDistance;

  const BearState({
    this.lastCheckinLocalDate,
    this.baseDistance = 5,
    this.lastShownDistance = 5,
  });

  BearState copyWith({
    DateTime? lastCheckinLocalDate,
    int? baseDistance,
    int? lastShownDistance,
  }) {
    return BearState(
      lastCheckinLocalDate: lastCheckinLocalDate ?? this.lastCheckinLocalDate,
      baseDistance: baseDistance ?? this.baseDistance,
      lastShownDistance: lastShownDistance ?? this.lastShownDistance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastCheckinLocalDate': lastCheckinLocalDate?.toIso8601String(),
      'baseDistance': baseDistance,
      'lastShownDistance': lastShownDistance,
    };
  }

  factory BearState.fromJson(Map<String, dynamic> json) {
    return BearState(
      lastCheckinLocalDate: json['lastCheckinLocalDate'] != null
          ? DateTime.parse(json['lastCheckinLocalDate'])
          : null,
      baseDistance: json['baseDistance'] ?? 5,
      lastShownDistance: json['lastShownDistance'] ?? 5,
    );
  }
}

class BearEventResult {
  final String eventType; // "maintain", "decrement", or "idle"
  final int distanceAfter;
  final String? imageAssetPath;
  final int? previousDistance;

  const BearEventResult({
    required this.eventType,
    required this.distanceAfter,
    this.imageAssetPath,
    this.previousDistance,
  });
}
