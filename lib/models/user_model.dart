import 'package:lucasbeatsfederacao/models/role_model.dart'; // Importar Role

class User {
  final String id;
  final String username;

  final String? avatar;
  final String? bio;
  final String status;
  final String? clanId; // Pode ser nulo se não tiver clã
  final String? clanName; // Adicionado: Nome do clã
  final String? clanTag; // Adicionado: Tag do clã
  final Role clanRole; // Alterado para Role
  final String? federationId; // Pode ser nulo
  final String? federationName; // Adicionado: Nome da federação
  final String? federationTag; // Adicionado: Tag da federação
  final Role role; // Alterado para Role
  final bool online;
  final DateTime ultimaAtividade;
  final DateTime lastSeen;
  final DateTime? createdAt; // Adicionado: Data de criação do usuário

  User({
    required this.id,
    required this.username,
    this.avatar, // Default value is null
    this.bio = 'Sem biografia.',
    this.status = 'offline',
    this.clanId,
    this.clanName,
    this.clanTag,
    this.clanRole = Role.member, // Valor padrão como enum
    this.federationId,
    this.federationName,
    this.federationTag,
    this.role = Role.user, // Valor padrão como enum
    this.online = false,
    required this.ultimaAtividade,
    required this.lastSeen,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper function to safely get a string from a potentially nested object
    String? _getStringOrIdFromMap(dynamic value) {
      if (value is String) {
        return value;
      } else if (value is Map<String, dynamic>) {
        return value['id'] as String?;
      }
      return null;
    }

    // Helper function to safely get a name from a potentially nested object
    String? _getNameFromMap(dynamic value) {
      if (value is Map<String, dynamic>) {
        return value['name'] as String?;
      }
      return null;
    }

    // Helper function to safely get a tag from a potentially nested object
    String? _getTagFromMap(dynamic value) {
      if (value is Map<String, dynamic>) {
        return value['tag'] as String?;
      }
      return null;
    }

    // Safely get clan and federation data
    final dynamic clanData = json['clan'];
    final dynamic federationData = json['federation'];

    return User(
      id: json['_id'] as String,
      username: json['username'] as String,

      avatar: json['avatar'] as String?, // Default is null if json['avatar'] is null
      bio: json['bio'] as String?,
      status: json['status'] as String? ?? 'offline',

      // Handle clan data which might be a String ID or a Map object
      clanId: _getStringOrIdFromMap(clanData),
      clanName: _getNameFromMap(clanData),
      clanTag: _getTagFromMap(clanData),
      clanRole: roleFromString(json['clanRole'] as String?), // Assuming clanRole is always a string

      // Handle federation data which might be a String ID or a Map object
      federationId: _getStringOrIdFromMap(federationData),
      federationName: _getNameFromMap(federationData),
      federationTag: _getTagFromMap(federationData),
      role: roleFromString(json['role'] as String?), // Assuming role is always a string

      online: json['online'] as bool? ?? false,
      ultimaAtividade: DateTime.parse(json['ultimaAtividade'] as String),
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,

      'avatar': avatar,
      'bio': bio,
      'status': status,
      'clanId': clanId,
      'clanName': clanName,
      'clanTag': clanTag,
      'clanRole': roleToString(clanRole), // Convertendo de enum para string
      'federationId': federationId,
      'federationName': federationName,
      'federationTag': federationTag,
      'role': roleToString(role), // Convertendo de enum para string
      'online': online,
      'ultimaAtividade': ultimaAtividade.toIso8601String(),
      'lastSeen': lastSeen.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Getter para isOnline (compatibilidade com backend)
  bool get isOnline => online; // Já existe a propriedade 'online'

  // Getter para tag (se houver um campo 'tag' no backend para o usuário)
  String? get tag => federationTag; // Usando federationTag como 'tag' se aplicável

  // Getter para 'clan' e 'federation' para compatibilidade com o código existente
  String? get clan => clanId;
  String? get federation => federationId;
}
