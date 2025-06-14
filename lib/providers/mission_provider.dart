import 'package:flutter/material.dart';
import 'package:lucasbeatsfederacao/models/mission_model.dart';
import 'package:lucasbeatsfederacao/services/mission_service.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';

class MissionProvider extends ChangeNotifier {
  final MissionService _missionService;
  
  List<Mission> _dailyMissions = [];
  List<Mission> _weeklyMissions = [];
  List<Mission> _clanMissions = [];
  
  bool _isLoading = false;
  String? _error;

  MissionProvider(this._missionService);

  // Getters
  List<Mission> get dailyMissions => _dailyMissions;
  List<Mission> get weeklyMissions => _weeklyMissions;
  List<Mission> get clanMissions => _clanMissions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Carregar todas as missões
  Future<void> loadAllMissions(String userId, String? clanId) async {
    _setLoading(true);
    _error = null;

    try {
      final results = await Future.wait([
        _missionService.getDailyMissions(userId),
        _missionService.getWeeklyMissions(userId),
        _missionService.getClanMissions(clanId ?? ''),
      ]);

      _dailyMissions = results[0];
      _weeklyMissions = results[1];
      _clanMissions = results[2];

      Logger.info('Missões carregadas: ${_dailyMissions.length} diárias, ${_weeklyMissions.length} semanais, ${_clanMissions.length} do clã');
    } catch (e) {
      _error = 'Erro ao carregar missões: ${e.toString()}';
      Logger.error('Erro ao carregar missões', error: e);
    } finally {
      _setLoading(false);
    }
  }

  // Carregar apenas missões diárias
  Future<void> loadDailyMissions(String userId) async {
    try {
      _dailyMissions = await _missionService.getDailyMissions(userId);
      notifyListeners();
    } catch (e) {
      Logger.error('Erro ao carregar missões diárias', error: e);
    }
  }

  // Carregar apenas missões semanais
  Future<void> loadWeeklyMissions(String userId) async {
    try {
      _weeklyMissions = await _missionService.getWeeklyMissions(userId);
      notifyListeners();
    } catch (e) {
      Logger.error('Erro ao carregar missões semanais', error: e);
    }
  }

  // Carregar apenas missões do clã (QRR)
  Future<void> loadClanMissions(String clanId) async {
    try {
      _clanMissions = await _missionService.getClanMissions(clanId);
      notifyListeners();
    } catch (e) {
      Logger.error('Erro ao carregar missões do clã', error: e);
    }
  }

  // Confirmar presença em missão QRR
  Future<bool> confirmPresence(String missionId, String userId) async {
    try {
      final success = await _missionService.confirmPresence(missionId, userId);
      if (success) {
        _addConfirmedMember(missionId, userId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      Logger.error('Erro ao confirmar presença', error: e);
      return false;
    }
  }

  // Adicionar estratégia (imagem) em missão QRR
  Future<bool> addStrategyMedia(String missionId, String mediaUrl) async {
    try {
      final success = await _missionService.addStrategyMedia(missionId, mediaUrl);
      if (success) {
        _addStrategyMediaLocal(missionId, mediaUrl);
        notifyListeners();
      }
      return success;
    } catch (e) {
      Logger.error('Erro ao adicionar estratégia', error: e);
      return false;
    }
  }

  // Cancelar missão QRR
  Future<bool> cancelMission(String missionId) async {
    try {
      final success = await _missionService.cancelMission(missionId);
      if (success) {
        _updateMissionStatus(missionId, 'cancelled');
        notifyListeners();
      }
      return success;
    } catch (e) {
      Logger.error('Erro ao cancelar missão', error: e);
      return false;
    }
  }

  // Resgatar recompensa de missão
  Future<bool> claimMissionReward(String missionId) async {
    try {
      final success = await _missionService.claimMissionReward(missionId);
      if (success) {
        _updateMissionStatus(missionId, 'completed');
        notifyListeners();
      }
      return success;
    } catch (e) {
      Logger.error('Erro ao resgatar recompensa', error: e);
      return false;
    }
  }

  // Atualizar progresso de missão
  Future<bool> updateMissionProgress(String missionId, int progress) async {
    try {
      final success = await _missionService.updateMissionProgress(missionId, progress);
      if (success) {
        _updateMissionProgress(missionId, progress);
        notifyListeners();
      }
      return success;
    } catch (e) {
      Logger.error('Erro ao atualizar progresso', error: e);
      return false;
    }
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _updateMissionStatus(String missionId, String status) {
    _updateMissionInList(_dailyMissions, missionId, status: status);
    _updateMissionInList(_weeklyMissions, missionId, status: status);
    _updateMissionInList(_clanMissions, missionId, status: status);
  }

  void _updateMissionProgress(String missionId, int progress) {
    _updateMissionInList(_dailyMissions, missionId, currentProgress: progress);
    _updateMissionInList(_weeklyMissions, missionId, currentProgress: progress);
    _updateMissionInList(_clanMissions, missionId, currentProgress: progress);
  }

  void _addConfirmedMember(String missionId, String userId) {
    for (var mission in _clanMissions) {
      if (mission.id == missionId && !mission.confirmedMembers.contains(userId)) {
        mission.confirmedMembers.add(userId);
      }
    }
  }

  void _addStrategyMediaLocal(String missionId, String mediaUrl) {
    for (var mission in _clanMissions) {
      if (mission.id == missionId) {
        mission.strategyMediaUrls.add(mediaUrl);
      }
    }
  }

  void _updateMissionInList(List<Mission> missions, String missionId, {String? status, int? currentProgress}) {
    final index = missions.indexWhere((mission) => mission.id == missionId);
    if (index != -1) {
      final mission = missions[index];
      missions[index] = mission.copyWith(
        status: status ?? mission.status,
        currentProgress: currentProgress ?? mission.currentProgress,
      );
    }
  }

  // Estatísticas
  int get totalCompletedMissions {
    return _dailyMissions.where((m) => m.isCompleted).length +
           _weeklyMissions.where((m) => m.isCompleted).length +
           _clanMissions.where((m) => m.status == 'completed').length;
  }

  int get totalMissions {
    return _dailyMissions.length + _weeklyMissions.length + _clanMissions.length;
  }

  double get completionPercentage {
    if (totalMissions == 0) return 0.0;
    return totalCompletedMissions / totalMissions;
  }

  // Limpar dados
  void clear() {
    _dailyMissions.clear();
    _weeklyMissions.clear();
    _clanMissions.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
