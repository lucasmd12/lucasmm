enum MissionType {
  daily,
  weekly,
  clan,
  special,
  qrr, // Novo tipo para diferenciar QRR das demais missões
}

class ClanTarget {
  final String clanId;
  final String tag;
  final String name;
  final String flagUrl;

  ClanTarget({
    required this.clanId,
    required this.tag,
    required this.name,
    required this.flagUrl,
  });

  factory ClanTarget.fromJson(Map<String, dynamic> json) {
    return ClanTarget(
      clanId: json['clanId'] ?? '',
      tag: json['tag'] ?? '',
      name: json['name'] ?? '',
      flagUrl: json['flagUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clanId': clanId,
      'tag': tag,
      'name': name,
      'flagUrl': flagUrl,
    };
  }
}

class Mission {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final String createdBy;
  final String clanId;
  final DateTime createdAt;
  final String status;
  final int neededMembers;
  final String meetingPoint;
  final DateTime expiresAt;
  final String server;
  final String focusPoint;
  final List<ClanTarget> againstClans; // Clãs alvos
  final List<String> againstMediaUrls; // Prints dos adversários
  final String againstManual; // Texto livre para adversários não cadastrados
  final String mapImageUrl; // Print do mapa/estratégia
  final List<String> strategyMediaUrls; // Uploads dos membros (estratégias)
  final List<String> confirmedMembers; // Quem confirmou presença

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdBy,
    required this.clanId,
    required this.createdAt,
    required this.status,
    required this.neededMembers,
    required this.meetingPoint,
    required this.expiresAt,
    required this.server,
    required this.focusPoint,
    required this.againstClans,
    required this.againstMediaUrls,
    required this.againstManual,
    required this.mapImageUrl,
    required this.strategyMediaUrls,
    required this.confirmedMembers,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: _missionTypeFromString(json['type']),
      createdBy: json['createdBy'] ?? '',
      clanId: json['clanId'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'] ?? 'active',
      neededMembers: json['neededMembers'] ?? 0,
      meetingPoint: json['meetingPoint'] ?? '',
      expiresAt: DateTime.parse(json['expiresAt']),
      server: json['server'] ?? '',
      focusPoint: json['focusPoint'] ?? '',
      againstClans: (json['againstClans'] as List<dynamic>? ?? [])
          .map((e) => ClanTarget.fromJson(e))
          .toList(),
      againstMediaUrls: List<String>.from(json['againstMediaUrls'] ?? []),
      againstManual: json['againstManual'] ?? '',
      mapImageUrl: json['mapImageUrl'] ?? '',
      strategyMediaUrls: List<String>.from(json['strategyMediaUrls'] ?? []),
      confirmedMembers: List<String>.from(json['confirmedMembers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': _missionTypeToString(type),
      'createdBy': createdBy,
      'clanId': clanId,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'neededMembers': neededMembers,
      'meetingPoint': meetingPoint,
      'expiresAt': expiresAt.toIso8601String(),
      'server': server,
      'focusPoint': focusPoint,
      'againstClans': againstClans.map((e) => e.toJson()).toList(),
      'againstMediaUrls': againstMediaUrls,
      'againstManual': againstManual,
      'mapImageUrl': mapImageUrl,
      'strategyMediaUrls': strategyMediaUrls,
      'confirmedMembers': confirmedMembers,
    };
  }
}

MissionType _missionTypeFromString(String? typeString) {
  switch (typeString?.toLowerCase()) {
    case 'daily':
      return MissionType.daily;
    case 'weekly':
      return MissionType.weekly;
    case 'clan':
      return MissionType.clan;
    case 'special':
      return MissionType.special;
    case 'qrr':
      return MissionType.qrr;
    default:
      return MissionType.daily;
  }
}

String _missionTypeToString(MissionType type) {
  switch (type) {
    case MissionType.daily:
      return 'daily';
    case MissionType.weekly:
      return 'weekly';
    case MissionType.clan:
      return 'clan';
    case MissionType.special:
      return 'special';
    case MissionType.qrr:
      return 'qrr';
  }
}
