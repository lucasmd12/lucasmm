import 'package:lucasbeatsfederacao/models/mission_model.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';
import 'package:lucasbeatsfederacao/services/api_service.dart';

class MissionService {
  final ApiService _apiService;

  MissionService(this._apiService);

  // Missões diárias
  Future<List<Mission>> getDailyMissions(String userId) async {
    try {
      final response = await _apiService.get('missions/daily?userId=$userId');
      if (response != null && response is List) {
        return response.map((data) => Mission.fromJson(data)).toList();
      }
    } catch (e) {
      Logger.error('Erro ao buscar missões diárias', error: e);
    }
    return _getMockDailyMissions();
  }

  // Missões semanais
  Future<List<Mission>> getWeeklyMissions(String userId) async {
    try {
      final response = await _apiService.get('missions/weekly?userId=$userId');
      if (response != null && response is List) {
        return response.map((data) => Mission.fromJson(data)).toList();
      }
    } catch (e) {
      Logger.error('Erro ao buscar missões semanais', error: e);
    }
    return _getMockWeeklyMissions();
  }

  // Missões de clã / QRR (usando o endpoint correto!)
  Future<List<Mission>> getClanMissions(String clanId) async {
    if (clanId.isEmpty) return [];
    try {
      // ATENÇÃO: endpoint correto do backend para QRR
      final response = await _apiService.get('clan-missions/clan/$clanId');
      if (response != null && response is List) {
        return response.map((data) => Mission.fromJson(data)).toList();
      }
    } catch (e) {
      Logger.error('Erro ao buscar missões do clã', error: e);
    }
    return _getMockClanMissions();
  }

  // Confirmar presença em missão QRR
  Future<bool> confirmPresence(String missionId, String userId) async {
    try {
      final response = await _apiService.post('clan-missions/$missionId/confirm', {
        'userId': userId,
      });
      return response != null;
    } catch (e) {
      Logger.error('Erro ao confirmar presença', error: e);
      return false;
    }
  }

  // Adicionar estratégia (imagem) em missão QRR
  Future<bool> addStrategyMedia(String missionId, String mediaUrl) async {
    try {
      final response = await _apiService.post('clan-missions/$missionId/strategy', {
        'mediaUrl': mediaUrl,
      });
      return response != null;
    } catch (e) {
      Logger.error('Erro ao adicionar estratégia', error: e);
      return false;
    }
  }

  // Cancelar missão QRR
  Future<bool> cancelMission(String missionId) async {
    try {
      final response = await _apiService.post('clan-missions/$missionId/cancel', {});
      return response != null;
    } catch (e) {
      Logger.error('Erro ao cancelar missão', error: e);
      return false;
    }
  }

  // Resgatar recompensa de missão (se aplicável)
  Future<bool> claimMissionReward(String missionId) async {
    try {
      final response = await _apiService.post('missions/$missionId/claim', {});
      return response != null;
    } catch (e) {
      Logger.error('Erro ao resgatar recompensa da missão', error: e);
      return false;
    }
  }

  // Atualizar progresso de missão
  Future<bool> updateMissionProgress(String missionId, int progress) async {
    try {
      final response = await _apiService.put('missions/$missionId/progress', {
        'progress': progress,
      });
      return response != null;
    } catch (e) {
      Logger.error('Erro ao atualizar progresso da missão', error: e);
      return false;
    }
  }

  // Missões mock para desenvolvimento
  List<Mission> _getMockDailyMissions() {
    return [
      Mission(
        id: 'daily_1',
        title: 'Primeira Chamada',
        description: 'Faça sua primeira chamada de voz do dia',
        type: MissionType.daily,
        currentProgress: 0,
        targetProgress: 1,
        rewardDescription: '50 XP',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      ),
      Mission(
        id: 'daily_2',
        title: 'Conversador Ativo',
        description: 'Envie 10 mensagens em canais de texto',
        type: MissionType.daily,
        currentProgress: 3,
        targetProgress: 10,
        rewardDescription: '30 XP',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      ),
      Mission(
        id: 'daily_3',
        title: 'Tempo Online',
        description: 'Fique online por 30 minutos',
        type: MissionType.daily,
        currentProgress: 15,
        targetProgress: 30,
        rewardDescription: '40 XP',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      ),
    ];
  }

  List<Mission> _getMockWeeklyMissions() {
    return [
      Mission(
        id: 'weekly_1',
        title: 'Mestre das Chamadas',
        description: 'Participe de 20 chamadas de voz esta semana',
        type: MissionType.weekly,
        currentProgress: 8,
        targetProgress: 20,
        rewardDescription: '200 XP + Badge',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      ),
      Mission(
        id: 'weekly_2',
        title: 'Socialização',
        description: 'Converse com 5 membros diferentes do clã',
        type: MissionType.weekly,
        currentProgress: 2,
        targetProgress: 5,
        rewardDescription: '150 XP',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      ),
    ];
  }

  List<Mission> _getMockClanMissions() {
    return [
      Mission(
        id: 'clan_1',
        title: 'União do Clã',
        description: 'Todos os membros devem participar de pelo menos uma chamada',
        type: MissionType.clan,
        currentProgress: 12,
        targetProgress: 20,
        rewardDescription: 'Banner especial do clã',
        expiresAt: DateTime.now().add(const Duration(days: 14)),
        // Adicione campos QRR mock se quiser testar
        mapImageUrl: 'https://exemplo.com/mapa.png',
        server: 'Servidor Alpha',
        focusPoint: 'Castelo Central',
        meetingPoint: 'Praça do Clã',
        neededMembers: 20,
        againstClans: [
          ClanTarget(
            clanId: 'c2',
            tag: 'TAG',
            name: 'Clã Inimigo',
            flagUrl: 'https://exemplo.com/flag.png',
          ),
        ],
        strategyMediaUrls: [],
        confirmedMembers: [],
      ),
      Mission(
        id: 'clan_2',
        title: 'Recrutamento',
        description: 'Adicione 3 novos membros ao clã',
        type: MissionType.clan,
        currentProgress: 1,
        targetProgress: 3,
        rewardDescription: 'Slot extra de canal',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
    ];
  }
}
