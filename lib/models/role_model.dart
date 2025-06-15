/// Enum de papéis do usuário alinhado com o backend.
/// Se precisar de papéis extras no frontend, adicione e ANOTE para futura inclusão no backend.
enum Role {
  ADM,         // Backend: "ADM"
  Leader,      // Backend: "Leader"
  SubLeader,   // Backend: "SubLeader"
  Member,      // Backend: "Member"
  User,        // Backend: "User"
  // guest,    // Exclusivo do frontend, se necessário para lógica local (ex: usuário não autenticado)
}

/// Converte string do backend para enum Role.
/// ATENÇÃO: Sempre alinhe os valores aqui com o backend!
/// Exemplo de uso: Role userRole = roleFromString(json['role']);
Role roleFromString(String? roleString) {
  switch (roleString) {
    case 'ADM':
      return Role.ADM;
    case 'Leader':
      return Role.Leader;
    case 'SubLeader':
      return Role.SubLeader;
    case 'Member':
      return Role.Member;
    case 'User':
      return Role.User;
    // case 'guest':
    //   return Role.guest; // Se precisar lógica local
    default:
      return Role.User; // Valor padrão seguro
  }
}

/// Converte enum Role para string do backend.
/// Exemplo de uso: String roleStr = roleToString(user.role);
String roleToString(Role role) {
  switch (role) {
    case Role.ADM:
      return 'ADM';
    case Role.Leader:
      return 'Leader';
    case Role.SubLeader:
      return 'SubLeader';
    case Role.Member:
      return 'Member';
    case Role.User:
      return 'User';
    // case Role.guest:
    //   return 'guest';
  }
}

/// ANOTAÇÕES PARA O BACKEND:
/// - Se você usar papéis extras no frontend (ex: guest), ANOTE aqui para migrar depois.
/// - Sempre alinhe o enum e as funções helpers com o backend para evitar bugs de permissão e navegação.

/// EXEMPLO DE USO NO MODELO:
/// ```
/// final user = UserModel(role: roleFromString(json['role']));
/// print(roleToString(user.role)); // Envia para o backend
/// ```
