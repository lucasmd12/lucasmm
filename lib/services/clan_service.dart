import 'package:lucasbeatsfederacao/models/clan_model.dart';
import 'package:lucasbeatsfederacao/services/api_service.dart';
import 'package:lucasbeatsfederacao/services/auth_service.dart';
import 'package:lucasbeatsfederacao/models/channel_model.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';
import 'package:lucasbeatsfederacao/models/role_model.dart';
import 'package:lucasbeatsfederacao/models/member_model.dart';
import 'package:flutter/material.dart'; // Import for ChangeNotifier

class ClanService with ChangeNotifier { // Adicionado ChangeNotifier
  final ApiService _apiService;
  final AuthService _authService;

  List<Clan> _clans = [];
  bool _isLoading = false;

  List<Clan> get clans => _clans;
  bool get isLoading => _isLoading;

  ClanService(this._apiService, this._authService);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<List<Clan>> fetchClansByFederation(String federationId) async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/api/federations/$federationId/clans', requireAuth: true);
      if (response != null && response['success'] == true && response['data'] is List) {
        _clans = (response['data'] as List).map((json) => Clan.fromMap(json)).toList();
        Logger.info('Fetched ${_clans.length} clans for federation $federationId.');
        return _clans;
      } else {
        Logger.warning('Unexpected response format when fetching clans for federation $federationId: $response');
        _clans = [];
        return [];
      }
    } catch (e, s) {
      Logger.error('Error fetching clans for federation $federationId', error: e, stackTrace: s);
      _clans = [];
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<Clan?> getClanDetails(String clanId) async {
    try {
      final response = await _apiService.get('/api/clans/$clanId', requireAuth: true);
      if (response != null) {
        return Clan.fromMap(response);
      }
    } catch (e) {
      Logger.error('Error fetching clan details for $clanId: $e');
    }
    return null;
  }

  Future<List<Member>> getClanMembers(String clanId) async {
    try {
      final response = await _apiService.get('/api/clans/$clanId/members', requireAuth: true);
      if (response != null && response is Map<String, dynamic> && response.containsKey('members') && response['members'] is List) {
        final membersData = response['members'] as List;
        List<Member> members = [];
        for (var memberJson in membersData) {
          members.add(Member.fromJson(memberJson));
        }
        Logger.info('Fetched ${members.length} members for clan $clanId.');
        return members;
      } else {
        Logger.warning('Unexpected response format when fetching members for clan $clanId: $response');
      }
    } catch (e, s) {
      Logger.error('Error fetching members for clan $clanId', error: e, stackTrace: s);
    }
    return [];
  }

  Future<List<Channel>> getClanChannels(String clanId) async {
    try {
      final endpoint = '/api/voice-channels/clan/$clanId';
      final response = await _apiService.get(endpoint, requireAuth: true);
      if (response != null && response is Map<String, dynamic> && response.containsKey('clanVoiceChannels') && response['clanVoiceChannels'] is List) {
        final channels = (response['clanVoiceChannels'] as List).map((data) => Channel.fromMap(data)).toList();
        Logger.info('Fetched ${channels.length} voice channels for clan $clanId.');
        return channels;
      } else {
        Logger.warning('Unexpected response format when fetching voice channels for clan $clanId: $response');
      }
    } catch (e, s) {
      Logger.error('Error fetching voice channels for clan $clanId', error: e, stackTrace: s);
    }
    return [];
  }

  Future<bool> addMember(String clanId, String userIdToAdd) async {
    final currentUser = _authService.currentUser;
    final clan = await getClanDetails(clanId);
    if (currentUser == null || clan == null) return false;

    String? currentUserRoleInClan;
    if (clan.memberRoles != null) {
      for (var roleMap in clan.memberRoles!) {
        if (roleMap['user'] == currentUser.id) {
          currentUserRoleInClan = roleMap['role'];
          break;
        }
      }
    }

    bool isLeader = currentUser.id == clan.leaderId;
    bool isSubLeader = currentUserRoleInClan == roleToString(Role.subLeader);

    if (!(isLeader || isSubLeader)) {
      Logger.warning('Permission Denied [Add Member]: Only Leader/SubLeader can add members.');
      return false;
    }

    try {
      final response = await _apiService.post('/api/clans/$clanId/members', {'userId': userIdToAdd}, requireAuth: true);
      return response != null;
    } catch (e) {
      Logger.error('Error adding member $userIdToAdd to clan $clanId: $e');
      return false;
    }
  }

  Future<bool> removeMember(String userIdToRemove) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null || currentUser.clanId == null) { // Usando clanId
      Logger.warning("Permission Denied [Remove Member]: User not in a clan.");
      return false;
    }
    final clanId = currentUser.clanId!; // Usando clanId

    try {
      await _apiService.delete('/api/clans/$clanId/members/$userIdToRemove', requireAuth: true);
      return true;
    } catch (e) {
      Logger.error('Error removing member $userIdToRemove from clan $clanId: $e');
      rethrow;
    }
  }

  Future<bool> promoteMember(String userIdToPromote) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null || currentUser.clanId == null) { // Usando clanId
      Logger.warning("Permission Denied [Promote Member]: User not in a clan.");
      return false;
    }
    final clanId = currentUser.clanId!; // Usando clanId

    try {
      final response = await _apiService.put('/api/clans/$clanId/members/$userIdToPromote/promote', {}, requireAuth: true);
      return response != null;
    } catch (e) {
      Logger.error('Error promoting member $userIdToPromote in clan $clanId: $e');
      rethrow;
    }
  }

  Future<bool> demoteMember(String userIdToDemote) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null || currentUser.clanId == null) { // Usando clanId
      Logger.warning("Permission Denied [Demote Member]: User not in a clan.");
      return false;
    }
    final clanId = currentUser.clanId!; // Usando clanId

    try {
      final response = await _apiService.put('/api/clans/$clanId/members/$userIdToDemote/demote', {}, requireAuth: true);
      return response != null;
    } catch (e) {
      Logger.error('Error demoting member $userIdToDemote in clan $clanId: $e');
      rethrow;
    }
  }

  Future<Clan?> getClanById(String clanId) async {
    return await getClanDetails(clanId);
  }

  Future<Clan?> updateClanDetails(String clanId, {String? name, String? bannerImageUrl, String? tag}) async {
    final currentUser = _authService.currentUser;
    final clan = await getClanDetails(clanId);
    if (currentUser == null || clan == null) return null;

    String? currentUserRoleInClan;
    if (clan.memberRoles != null) {
      for (var roleMap in clan.memberRoles!) {
        if (roleMap['user'] == currentUser.id) {
          currentUserRoleInClan = roleMap['role'];
          break;
        }
      }
    }

    bool isLeader = currentUser.id == clan.leaderId;
    bool isSubLeader = currentUserRoleInClan == roleToString(Role.subLeader);

    if (!(isLeader || isSubLeader)) {
      Logger.warning('Permission Denied [Update Clan Details]: Only Leader/SubLeader can update details.');
      return null;
    }

    Map<String, dynamic> dataToUpdate = {};
    if (name != null) dataToUpdate['name'] = name;
    if (bannerImageUrl != null) dataToUpdate['bannerImageUrl'] = bannerImageUrl;
    if (tag != null) dataToUpdate['tag'] = tag;

    if (dataToUpdate.isEmpty) {
      Logger.info('No details provided to update for clan $clanId.');
      return clan;
    }

    try {
      final response = await _apiService.put('/api/clans/$clanId', dataToUpdate, requireAuth: true);
      if (response != null) {
        return Clan.fromMap(response);
      }
    } catch (e) {
      Logger.error('Error updating details for clan $clanId: $e');
    }
    return null;
  }
}


