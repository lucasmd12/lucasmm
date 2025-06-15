import 'package:voip_app/models/clan_model.dart';
import 'package:voip_app/services/api_service.dart';
import 'package:voip_app/services/auth_service.dart';
import 'package:voip_app/utils/logger.dart';

class ClanService {
  final ApiService _apiService;
  final AuthService _authService;

  ClanService(this._apiService, this._authService);

  Future<Clan?> getClanDetails(String clanId) async {
    try {
      final response = await _apiService.get('/api/clans/$clanId', requireAuth: true);
      if (response != null) {
        return Clan.fromJson(response);
      }
    } catch (e) {
      Logger.error('Error fetching clan details for $clanId: $e');
    }
    return null;
  }

  // TODO: REVISAR: getClanMembers pode ser redundante se o Clan model já vier populado.
  // Se necessário, esta função pode ser adaptada para buscar detalhes completos de membros.
  /*
  Future<List<Member>> getClanMembers(String clanId) async {
    try {
      final response = await _apiService.get('/api/clans/$clanId/members', requireAuth: true);
      if (response != null && response is List) {
        return response.map((data) => Member.fromJson(data)).toList();
      }
    } catch (e) {
      Logger.error('Error fetching clan members for $clanId: $e');
    }
    return [];
  }
  */

  // TODO: REVISAR: O backend não tem um endpoint /api/clans/{clanId}/channels diretamente.
  // Canais de chat são gerenciados via clan-chat ou federation-chat.
  // Esta função pode ser removida ou adaptada para buscar canais de chat específicos.
  /*
  Future<List<ChatChannelModel>> getClanChannels(String clanId, {String type = 'text'}) async {
    final UserModel? currentUser = _authService.currentUser;
    if (currentUser == null || currentUser.clanId != clanId) {
        Logger.warning('Permission Denied [Get Channels]: User not part of the clan or not logged in.');
        return [];
    }

    try {
      final endpoint = '/api/clans/$clanId/channels?type=$type';
      final response = await _apiService.get(endpoint, requireAuth: true);
      if (response != null && response is List) {
        final channels = response.map((data) => ChatChannelModel.fromJson(data)).toList();
        Logger.info('Fetched ${channels.length} $type channels for clan $clanId.');
        return channels;
      } else {
        Logger.warning('Unexpected response format when fetching $type channels for clan $clanId: $response');
      }
    } catch (e) {
      Logger.error('Error fetching $type channels for clan $clanId: $e');
    }
    return [];
  }
  */

  Future<bool> addMember(String clanId, String userIdToAdd) async {
    final currentUser = _authService.currentUser;
    final clan = await getClanDetails(clanId);
    if (currentUser == null || clan == null || !(currentUser.id == clan.leaderId || (clan.subLeaders?.contains(currentUser.id) ?? false))) {
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

  Future<bool> removeMember(String clanId, String userIdToRemove) async {
    final currentUser = _authService.currentUser;
    final clan = await getClanDetails(clanId);

    if (currentUser == null || clan == null) {
      Logger.warning("Permission Denied [Remove Member]: Cannot verify user or clan.");
      return false;
    }

    bool isSelfRemoval = userIdToRemove == currentUser.id;
    bool isLeaderOrSub = currentUser.id == clan.leaderId || (clan.subLeaders?.contains(currentUser.id) ?? false);
    bool isRemovingLeader = userIdToRemove == clan.leaderId;
    bool canRemove = isSelfRemoval || (isLeaderOrSub && !isRemovingLeader);

    if (!canRemove) {
       Logger.warning("Permission Denied [Remove Member]: Action not allowed.");
       return false;
    }

    try {
      await _apiService.delete('/api/clans/$clanId/members/$userIdToRemove', requireAuth: true);
      return true;
    } catch (e) {
      Logger.error('Error removing member $userIdToRemove from clan $clanId: $e');
      return false;
    }
  }

  // TODO: REVISAR: O backend não tem um endpoint direto para 'updateMemberRole'.
  // A gestão de roles pode ser feita via 'memberRoles' no ClanModel ou por endpoints específicos de promoção/rebaixamento.
  // Esta função pode ser removida ou adaptada para usar os endpoints de federação/clã para promoção/rebaixamento.
  /*
  Future<bool> updateMemberRole(String clanId, String userId, Role newRole) async {
    if (newRole == Role.federationAdmin || newRole == Role.guest) {
        Logger.warning("Invalid role assignment.");
        return false;
    }

    final UserModel? currentUser = _authService.currentUser;
    final Clan? clan = await getClanDetails(clanId);
    if (currentUser == null || clan == null || currentUser.id != clan.leaderId) {
      Logger.warning("Permission Denied [Update Role]: Only Leader can change roles.");
      return false;
    }
    if (userId == clan.leaderId) {
       Logger.warning("Cannot change the leader's role directly via this method.");
       return false;
    }
    try {
      final response = await _apiService.put(
        '/api/clans/$clanId/members/$userId/role',
        {'role': roleToString(newRole)},
        requireAuth: true
      );
      return response != null;
    } catch (e) {
      Logger.error('Error updating role for member $userId in clan $clanId: $e');
      return false;
    }
  }
  */

  Future<Clan?> getClanById(String clanId) async {
    return await getClanDetails(clanId);
  }

  Future<Clan?> updateClanDetails(String clanId, {String? name, String? bannerImageUrl, String? tag}) async {
    final currentUser = _authService.currentUser;
    final clan = await getClanDetails(clanId);
    if (currentUser == null || clan == null || !(currentUser.id == clan.leaderId || (clan.subLeaders?.contains(currentUser.id) ?? false))) {
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
        return Clan.fromJson(response);
      }
    } catch (e) {
      Logger.error('Error updating details for clan $clanId: $e');
    }
    return null;
  }
}

