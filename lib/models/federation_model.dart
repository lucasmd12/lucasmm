// lib/models/federation_model.dart
import 'clan_model.dart';
import 'user_model.dart';

class FederationLeader {
  final String id;
  final String username;
  final String? avatar;

  FederationLeader({
    required this.id,
    required this.username,
    this.avatar,
  });

  factory FederationLeader.fromJson(Map<String, dynamic> json) {
    return FederationLeader(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? 'Unknown',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'avatar': avatar,
    };
  }
}

class FederationClan {
  final String id;
  final String name;
  final String? tag;

  FederationClan({
    required this.id,
    required this.name,
    this.tag,
  });

  factory FederationClan.fromJson(Map<String, dynamic> json) {
    return FederationClan(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Unknown Clan',
      tag: json['tag'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'tag': tag,
    };
  }
}

class FederationAlly {
  final String id;
  final String name;

  FederationAlly({
    required this.id,
    required this.name,
  });

  factory FederationAlly.fromJson(Map<String, dynamic> json) {
    return FederationAlly(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Unknown Federation',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

class Federation {
  final String id;
  final String name;
  final String? description;
  final String? rules;
  final String? banner;
  final FederationLeader? leader;
  final List<FederationClan> clans;
  final List<FederationAlly> allies;
  final List<FederationAlly> enemies;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Federation({
    required this.id,
    required this.name,
    this.description,
    this.rules,
    this.banner,
    this.leader,
    this.clans = const [],
    this.allies = const [],
    this.enemies = const [],
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor for creating a new Federation instance from a map (e.g., JSON from API)
  factory Federation.fromJson(Map<String, dynamic> json) {
    var clanListFromJson = json['clans'] as List? ?? [];
    List<FederationClan> clanList = clanListFromJson.map((i) => FederationClan.fromJson(i)).toList();

    var alliesListFromJson = json['allies'] as List? ?? [];
    List<FederationAlly> alliesList = alliesListFromJson.map((i) => FederationAlly.fromJson(i)).toList();

    var enemiesListFromJson = json['enemies'] as List? ?? [];
    List<FederationAlly> enemiesList = enemiesListFromJson.map((i) => FederationAlly.fromJson(i)).toList();

    return Federation(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Default Federation Name',
      description: json['description'],
      rules: json['rules'],
      banner: json['banner'],
      leader: json['leader'] != null ? FederationLeader.fromJson(json['leader']) : null,
      clans: clanList,
      allies: alliesList,
      enemies: enemiesList,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  // Method for converting a Federation instance to a map (e.g., for sending to API)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'rules': rules,
      'banner': banner,
      'leader': leader?.toJson(),
      'clans': clans.map((clan) => clan.toJson()).toList(),
      'allies': allies.map((ally) => ally.toJson()).toList(),
      'enemies': enemies.map((enemy) => enemy.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper method to check if a new clan can be added (assuming max 10 clans)
  bool canAddClan() {
    return clans.length < 10;
  }

  // Helper method to get admin user ID (leader ID)
  String? get adminUserId => leader?.id;
}

