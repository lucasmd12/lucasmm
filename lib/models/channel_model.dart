import 'dart:convert';

enum ChannelType {
  text,
  voice,
}

class Channel {
  final String id;
  final String name;
  final ChannelType type;
  final String? clanId;
  final String? federationId;
  final List<String> members;
  final DateTime? createdAt;

  Channel({
    required this.id,
    required this.name,
    required this.type,
    this.clanId,
    this.federationId,
    this.members = const [],
    this.createdAt,
  });

  factory Channel.fromMap(Map<String, dynamic> map) {
    return Channel(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      type: ChannelType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => ChannelType.text,
      ),
      clanId: map['clanId'],
      federationId: map['federationId'],
      members: List<String>.from(map['members'] ?? []),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'clanId': clanId,
      'federationId': federationId,
      'members': members,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Channel.fromJson(String source) => Channel.fromMap(json.decode(source));
  String toJson() => json.encode(toMap());
}


