import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:voip_app/models/user_model.dart';
import 'package:voip_app/models/federation_model.dart';
import 'package:voip_app/models/clan_model.dart';
import 'package:voip_app/services/api_service.dart';
import 'package:voip_app/services/auth_service.dart';

class FederationService {
  final ApiService _apiService;
  final AuthService _authService;

  FederationService(this._apiService, this._authService);

  Future<List<Federation>> getAllFederations() async {
    try {
      final response = await _apiService.get('/api/federations', requireAuth: false);
      if (response != null && response['success'] == true && response['data'] is List) {
        final List<dynamic> federationsData = response['data'];
        return federationsData.map((json) => Federation.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching all federations: $e');
    }
    return [];
  }

  Future<Federation?> getFederationDetails(String federationId) async {
    try {
      final response = await _apiService.get('/api/federations/$federationId', requireAuth: false);
      if (response != null && response['success'] == true && response['data'] != null) {
        return Federation.fromJson(response['data']);
      }
    } catch (e) {
      debugPrint('Error fetching federation details: $e');
    }
    return null;
  }

  Future<Federation?> createFederation(Map<String, dynamic> federationData) async {
    try {
      final response = await _apiService.post('/api/federations', federationData, requireAuth: true);
      if (response != null && response['success'] == true && response['data'] != null) {
        return Federation.fromJson(response['data']);
      }
    } catch (e) {
      debugPrint('Error creating federation: $e');
    }
    return null;
  }

  Future<bool> deleteFederation(String federationId) async {
    try {
      final response = await _apiService.delete('/api/federations/$federationId', requireAuth: true);
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Error deleting federation: $e');
      return false;
    }
  }

  Future<bool> updateFederation(String federationId, Map<String, dynamic> updateData) async {
    try {
      final response = await _apiService.put('/api/federations/$federationId', updateData, requireAuth: true);
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Error updating federation: $e');
      return false;
    }
  }

  Future<bool> addClanToFederation(String federationId, String clanId) async {
    try {
      final response = await _apiService.put('/api/federations/$federationId/add-clan/$clanId', {}, requireAuth: true);
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Error adding clan to federation: $e');
      return false;
    }
  }

  Future<bool> removeClanFromFederation(String federationId, String clanId) async {
    try {
      final response = await _apiService.put('/api/federations/$federationId/remove-clan/$clanId', {}, requireAuth: true);
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Error removing clan from federation: $e');
      return false;
    }
  }

  Future<bool> promoteToSubLeader(String federationId, String userId) async {
    try {
      final response = await _apiService.put('/api/federations/$federationId/promote/$userId', {}, requireAuth: true);
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Error promoting user to sub-leader: $e');
      return false;
    }
  }

  Future<bool> demoteSubLeader(String federationId, String userId) async {
    try {
      final response = await _apiService.put('/api/federations/$federationId/demote/$userId', {}, requireAuth: true);
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Error demoting sub-leader: $e');
      return false;
    }
  }

  Future<bool> transferLeadership(String federationId, String userId) async {
    try {
      final response = await _apiService.put('/api/federations/$federationId/transfer/$userId', {}, requireAuth: true);
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Error transferring leadership: $e');
      return false;
    }
  }

  Future<bool> addAlly(String federationId, String allyId) async {
    try {
      final response = await _apiService.put('/api/federations/$federationId/ally/$allyId', {}, requireAuth: true);
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Error adding ally: $e');
      return false;
    }
  }

  Future<bool> addEnemy(String federationId, String enemyId) async {
    try {
      final response = await _apiService.put('/api/federations/$federationId/enemy/$enemyId', {}, requireAuth: true);
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Error adding enemy: $e');
      return false;
    }
  }
}


