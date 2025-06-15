import 'dart:convert';

class Mission {
  final String id;
  final String name;
  final String description;
  final String clanId;
  final DateTime scheduledTime;
  final int targetProgress; // quantidade que deve ser atingida
  final int currentProgress; // valor atual (controlado no frontend)

  Mission({
    required this.id,
    required this.name,
    required this.description,
    required this.clanId,
    required this.scheduledTime,
    this.targetProgress = 100,
    this.currentProgress = 0,
  });

  bool get isCompleted => currentProgress >= targetProgress;

  Mission copyWith({
    String? id,
    String? name,
    String? description,
    String? clanId,
    DateTime? scheduledTime,
    int? targetProgress,
    int? currentProgress,
  }) {
    return Mission(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      clanId: clanId ?? this.clanId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      targetProgress: targetProgress ?? this.targetProgress,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  factory Mission.fromMap(Map<String, dynamic> map) {
    return Mission(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      clanId: map['clan'] ?? '',
      scheduledTime: DateTime.parse(map['scheduledTime']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'clan': clanId,
      'scheduledTime': scheduledTime.toIso8601String(),
    };
  }

  factory Mission.fromJson(String source) => Mission.fromMap(json.decode(source));
  String toJson() => json.encode(toMap());
}

