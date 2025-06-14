// /home/ubuntu/lucasbeats_v4/project_android/lib/models/user_model.dart
import 'package:lucasbeatsfederacao/models/role_model.dart'; // Import Role enum

class UserModel {
  final String id;
  final String username;
  final String? email;
  final String? avatar;
  final String? clan;
  final String? clanRole;
  final String? federationRole;
  final DateTime? createdAt;
  final Role role;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    this.avatar,
    this.clan,
    this.clanRole,
    this.federationRole,
    this.createdAt,
    // CORREÇÃO: Usar Role.clanMember como padrão
    this.role = Role.clanMember,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"] ?? json["uid"] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      username: json["username"] ?? "Usuário Desconhecido",
      email: json["email"],
      avatar: json["avatar"],
      clan: json["clan"],
      clanRole: json["clanRole"],
      federationRole: json["federationRole"],
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
      // CORREÇÃO: Usar Role.clanMember como fallback
      role: roleFromString(json["federationRole"] ?? json["clanRole"]) ?? Role.clanMember,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "username": username,
      "email": email,
      "avatar": avatar,
      "clan": clan,
      "clanRole": clanRole,
      "federationRole": federationRole,
      "createdAt": createdAt?.toIso8601String(),
      "role": roleToString(role), // Use helper function
    };
  }
}

