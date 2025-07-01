import 'package:flutter/material.dart';
import 'package:lucasbeatsfederacao/models/user_model.dart';
import 'package:lucasbeatsfederacao/models/role_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserDashboardWidget extends StatelessWidget {
  final User user;

  const UserDashboardWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade800.withAlpha((0.8 * 255).round()),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _getRoleColor(user.role),
                  backgroundImage: user.avatar != null
                    ? NetworkImage(user.avatar)
                    : null,
                  child: user.avatar == null
                    ? Text(
                        user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getRoleDisplayName(user.role),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (user.federationTag != null && user.federationTag!.isNotEmpty) ...[ // Usando federationTag
                        const SizedBox(height: 4),
                        Text(
                          'Tag: ${user.federationTag}', // Usando federationTag
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusIndicator(user.isOnline), // Usando isOnline
              ],
            ),
            const SizedBox(height: 16),
            _buildUserStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isOnline) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isOnline ? Colors.green : Colors.red, // Cor baseada no status online
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildUserStats() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError || !snapshot.hasData) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Tempo Online', '0h 0m'),
                _buildStatColumn('Mensagens', '0'),
                _buildStatColumn('Chamadas', '0'),
              ],
            );
          }
          
          final stats = snapshot.data!;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Tempo Online', stats['onlineTime'] ?? '0h 0m'),
              _buildStatColumn('Mensagens', '${stats['totalMessages'] ?? 0}'),
              _buildStatColumn('Chamadas', '${stats['totalCalls'] ?? 0}'),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchUserStats() async {
    try {
      final response = await http.get(
        Uri.parse('${_getApiBaseUrl()}/api/stats/user/${user.id}'),
        headers: {
          // 'Authorization': 'Bearer ${_getAuthToken()}', // Removido temporariamente
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      // Silently fail and return empty stats
    }
    return {};
  }

  String _getApiBaseUrl() {
    // Assumindo que você tem acesso ao ApiService através do contexto
    return 'https://beckend-ydd1.onrender.com'; // URL do seu backend
  }

  String? _getAuthToken() {
    // Assumindo que você tem acesso ao token através do contexto
    return null; // Implementar conforme sua arquitetura
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(Role role) {
    switch (role) {
      case Role.federationAdmin:
        return Colors.red;
      case Role.clanLeader:
        return Colors.orange;
      case Role.clanSubLeader:
        return Colors.yellow.shade700;
      case Role.clanMember:
        return Colors.blue;
      case Role.guest:
        return Colors.grey;
      case Role.adm: // Adicionado ADM
        return Colors.red; // Cor para ADM
      case Role.user: // Adicionado User
        return Colors.blue; // Cor para User
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(Role role) {
    switch (role) {
      case Role.federationAdmin:
        return 'ADMINISTRADOR FEDERAÇÃO';
      case Role.clanLeader:
        return 'LÍDER CLÃ';
      case Role.clanSubLeader:
        return 'SUB-LÍDER CLÃ';
      case Role.clanMember:
        return 'MEMBRO CLÃ';
      case Role.guest:
        return 'CONVIDADO';
      case Role.adm:
        return 'ADMINISTRADOR';
      case Role.user:
        return 'USUÁRIO';
      default:
        return role.toString().split('.').last.toUpperCase();
    }
  }
}


