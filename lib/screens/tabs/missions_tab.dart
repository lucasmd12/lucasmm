import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voip_app/providers/auth_provider.dart';
import 'package:voip_app/providers/mission_provider.dart';
import 'package:voip_app/models/mission_model.dart';
import 'package:voip_app/utils/logger.dart';
import 'package:voip_app/widgets/mission_card.dart';

class MissionsTab extends StatefulWidget {
  const MissionsTab({super.key});

  @override
  State<MissionsTab> createState() => _MissionsTabState();
}

class _MissionsTabState extends State<MissionsTab> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final missionProvider = Provider.of<MissionProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        setState(() {
          _error = 'Usuário não autenticado';
          _isLoading = false;
        });
        return;
      }

      await missionProvider.loadAllMissions(currentUser.id, currentUser.clanId);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('Erro ao carregar missões', error: e);
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar missões: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(context);

    if (_isLoading || missionProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || missionProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? missionProvider.error!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadMissions();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    final dailyMissions = missionProvider.dailyMissions;
    final weeklyMissions = missionProvider.weeklyMissions;
    final clanMissions = missionProvider.clanMissions;

    return Column(
      children: [
        // Cabeçalho
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.assignment,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Missões',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadMissions,
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Atualizar missões',
              ),
            ],
          ),
        ),

        // Estatísticas rápidas
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade800.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Diárias',
                '${dailyMissions.where((m) => m.isCompleted).length}/${dailyMissions.length}',
                Colors.blue,
              ),
              _buildStatItem(
                'Semanais',
                '${weeklyMissions.where((m) => m.isCompleted).length}/${weeklyMissions.length}',
                Colors.green,
              ),
              _buildStatItem(
                'Clã',
                '${clanMissions.where((m) => m.isCompleted).length}/${clanMissions.length}',
                Colors.orange,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Abas de missões
        TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade400,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Diárias'),
            Tab(text: 'Semanais'),
            Tab(text: 'Clã'),
          ],
        ),

        // Conteúdo das abas
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMissionsList(context, dailyMissions, 'Nenhuma missão diária disponível'),
              _buildMissionsList(context, weeklyMissions, 'Nenhuma missão semanal disponível'),
              _buildMissionsList(context, clanMissions, 'Nenhuma missão do clã disponível', isClan: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
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

  Widget _buildMissionsList(BuildContext context, List<Mission> missions, String emptyMessage, {bool isClan = false}) {
    final missionProvider = Provider.of<MissionProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? '';

    if (missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMissions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final mission = missions[index];
          return MissionCard(
            mission: mission,
            onMissionTap: _handleMissionTap,
            // Botão de ação só para missões do clã
            onClanAction: isClan
                ? () async {
                    final success = await missionProvider.confirmPresence(mission.id, userId);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Presença confirmada!')),
                      );
                    }
                  }
                : null,
            isClanActionLoading: false, // Pode implementar loading se quiser
            clanActionLabel: 'Confirmar Presença',
          );
        },
      ),
    );
  }

  void _handleMissionTap(Mission mission) {
    if (mission.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missão já concluída!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(mission.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mission.description),
              const SizedBox(height: 16),
              Text(
                'Progresso: ${mission.currentProgress}/${mission.targetProgress}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: mission.currentProgress / mission.targetProgress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  mission.currentProgress >= mission.targetProgress 
                    ? Colors.green 
                    : Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Recompensa: ${mission.rewardDescription}',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // CAMPOS EXTRAS PARA MISSÕES QRR (Clã)
              if (mission.type == MissionType.qrr || mission.type == MissionType.clan) ...[
                const Divider(height: 24),
                if (mission.mapImageUrl != null && mission.mapImageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Image.network(
                      mission.mapImageUrl,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                  ),
                if (mission.server.isNotEmpty)
                  Text('Servidor: ${mission.server}'),
                if (mission.focusPoint.isNotEmpty)
                  Text('Foco: ${mission.focusPoint}'),
                if (mission.meetingPoint.isNotEmpty)
                  Text('Ponto de encontro: ${mission.meetingPoint}'),
                if (mission.neededMembers > 0)
                  Text('Membros necessários: ${mission.neededMembers}'),
                if (mission.againstClans.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Contra: ${mission.againstClans.map((c) => c.name).join(", ")}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                if (mission.againstManual != null && mission.againstManual!.isNotEmpty)
                  Text('Adversário manual: ${mission.againstManual}'),
                if (mission.againstMediaUrls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      spacing: 8,
                      children: mission.againstMediaUrls.map((url) => Image.network(url, width: 48, height: 48, fit: BoxFit.cover)).toList(),
                    ),
                  ),
                if (mission.strategyMediaUrls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      spacing: 8,
                      children: mission.strategyMediaUrls.map((url) => Image.network(url, width: 48, height: 48, fit: BoxFit.cover)).toList(),
                    ),
                  ),
                if (mission.confirmedMembers.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Confirmados: ${mission.confirmedMembers.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          if (mission.currentProgress >= mission.targetProgress && !mission.isCompleted)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _claimReward(mission);
              },
              child: const Text('Resgatar'),
            ),
        ],
      ),
    );
  }

  void _claimReward(Mission mission) {
    // Implementar resgate de recompensa
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recompensa resgatada: ${mission.rewardDescription}')),
    );
    setState(() {
      mission.isCompleted = true;
    });
  }
}
