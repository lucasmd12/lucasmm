import 'package:flutter/foundation.dart';
import 'package:lucasbeatsfederacao/models/message_model.dart';
import 'package:lucasbeatsfederacao/services/api_service.dart';
import 'package:lucasbeatsfederacao/services/firebase_service.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';
import 'package:lucasbeatsfederacao/services/auth_service.dart'; // Importar AuthService
import 'package:lucasbeatsfederacao/models/role_model.dart'; // Importar o role_model.dart para usar roleToString

class ChatService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FirebaseService? _firebaseService;
  final AuthService _authService; // Adicionar AuthService

  // Stores messages per chat entity (clanId or federationId)
  final Map<String, List<Message>> _messages = {};

  ChatService({FirebaseService? firebaseService, required AuthService authService}) 
      : _firebaseService = firebaseService,
        _authService = authService; // Inicializar AuthService

  // Send a message to a specific chat (clan or federation)
  Future<void> sendMessage({
    required String entityId,
    required String message,
    required String chatType, // 'clan', 'federation', ou 'global'
    String? fileUrl,
    String? messageType = 'text',
    String? fileName,
    int? fileSize,
  }) async {
    Logger.info("[ChatService] Sending message to $chatType $entityId: $message");

    final currentUser = _authService.currentUser; // Obter usuário atual
    if (currentUser == null) {
      throw Exception("Usuário não autenticado.");
    }

    // Tentar enviar via Firebase primeiro, se disponível
    if (_firebaseService != null) {
      try {
        // Construir o mapa 'data' para sendMessageToRoom
        final Map<String, dynamic> firebaseMessageData = { // Renomeado para evitar conflito
          'type': messageType ?? 'text',
          'fileUrl': fileUrl,
          'chatType': chatType,
          'entityId': entityId,
          'senderRole': roleToString(currentUser.role),
          'senderClanCustomRole': currentUser.clanRole != null ? roleToString(currentUser.clanRole) : null,
        };

        await _sendMessageViaFirebase(
          entityId: entityId,
          message: message,
          chatType: chatType,
          // Os parâmetros abaixo não são mais passados diretamente para _sendMessageViaFirebase
          // mas sim dentro do mapa firebaseMessageData
          senderId: currentUser.id,
          firebaseData: firebaseMessageData, // <--- CORREÇÃO AQUI: Passando o mapa de dados
        );
        return;
      } catch (e) {
        Logger.warning("Firebase message failed, falling back to API: $e");
      }
    }

    // Fallback para API REST
    await _sendMessageViaAPI(
      entityId: entityId,
      message: message,
      chatType: chatType,
      fileUrl: fileUrl,
      messageType: messageType,
      senderRole: roleToString(currentUser.role),
      senderClanCustomRole: currentUser.clanRole != null ? roleToString(currentUser.clanRole) : null,
    );
  }

  Future<void> _sendMessageViaFirebase({
    required String entityId,
    required String message,
    required String chatType,
    required String senderId,
    required Map<String, dynamic> firebaseData, // <--- CORREÇÃO AQUI: Novo parâmetro
    // Os parâmetros abaixo foram removidos pois agora estão dentro de firebaseData
    // String? fileUrl,
    // String? messageType,
    // String? senderRole,
    // String? senderClanCustomRole,
  }) async {
    String roomId;
    switch (chatType) {
      case 'clan':
        roomId = 'clan_$entityId';
        break;
      case 'federation':
        roomId = 'federation_$entityId';
        break;
      case 'global':
        roomId = 'global_chat';
        break;
      default:
        throw Exception("Invalid chat type: $chatType");
    }

    await _firebaseService!.sendMessageToRoom(
      roomId,
      senderId,
      message,
      data: firebaseData, // <--- CORREÇÃO AQUI: Passando o mapa 'data'
    );

    Logger.info("Message sent via Firebase to $roomId");
  }

  Future<void> _sendMessageViaAPI({
    required String entityId,
    required String message,
    required String chatType,
    String? fileUrl,
    String? messageType,
    String? senderRole,
    String? senderClanCustomRole,
  }) async {
    String endpoint;
    if (chatType == 'clan') {
      endpoint = "/api/clan-chat/$entityId/message";
    } else if (chatType == 'federation') {
      endpoint = "/api/federation-chat/$entityId/message";
    } else if (chatType == 'global') {
      endpoint = "/api/global-chat/message";
    } else {
      throw Exception("Invalid chat type: $chatType");
    }

    try {
      final response = await _apiService.post(
        endpoint,
        {
          "message": message,
          if (fileUrl != null) "fileUrl": fileUrl,
          if (messageType != null) "type": messageType,
          "senderRole": senderRole, // Enviar role geral
          "senderClanCustomRole": senderClanCustomRole, // Enviar cargo customizado
        },
        requireAuth: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final newMessage = Message.fromMap(response);
        String cacheKey = chatType == 'global' ? 'global' : entityId;
        if (_messages[cacheKey] == null) {
          _messages[cacheKey] = [];
        }
        _messages[cacheKey]!.add(newMessage);
        notifyListeners();
        Logger.info("Message sent successfully via API: ${newMessage.message}");
      } else {
        throw Exception("Failed to send message: Invalid response");
      }
    } catch (e) {
      Logger.error("Error sending message via API: ${e.toString()}");
      rethrow;
    }
  }

  // Get messages for a specific chat (clan, federation, or global)
  Future<List<Message>> getMessages({
    required String entityId,
    required String chatType, // 'clan', 'federation', ou 'global'
    int? page,
    int? limit,
  }) async {
    Logger.info("[ChatService] Getting messages for $chatType $entityId");

    String endpoint;
    if (chatType == 'clan') {
      endpoint = "/api/clan-chat/$entityId/messages";
    } else if (chatType == 'federation') {
      endpoint = "/api/federation-chat/$entityId/messages";
    } else if (chatType == 'global') {
      endpoint = "/api/global-chat/messages";
    } else {
      throw Exception("Invalid chat type: $chatType");
    }

    try {
      final response = await _apiService.get(endpoint, requireAuth: true);

      if (response != null && response is List) {
        final fetchedMessages = response.map((json) => Message.fromMap(json)).toList();
        String cacheKey = chatType == 'global' ? 'global' : entityId;
        _messages[cacheKey] = fetchedMessages;
        notifyListeners();
        Logger.info("Messages fetched successfully for $chatType $entityId");
        return fetchedMessages;
      } else {
        throw Exception("Failed to get messages: Invalid response");
      }
    } catch (e) {
      Logger.error("Error getting messages: ${e.toString()}");
      rethrow;
    }
  }

  // Listen to real-time messages from Firebase
  Stream<List<Message>> listenToMessages({
    required String entityId,
    required String chatType,
  }) {
    if (_firebaseService == null) {
      throw Exception("Firebase service not available for real-time messaging");
    }

    String roomId;
    switch (chatType) {
      case 'clan':
        roomId = 'clan_$entityId';
        break;
      case 'federation':
        roomId = 'federation_$entityId';
        break;
      case 'global':
        roomId = 'global_chat';
        break;
      default:
        throw Exception("Invalid chat type: $chatType");
    }

    return _firebaseService.listenToRoomMessages(roomId).map((event) {
      if (event.snapshot.value == null) {
        return <Message>[];
      }

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final messages = data.entries.map((entry) {
        final messageData = entry.value as Map<dynamic, dynamic>;
        return Message(
          id: entry.key,
          senderId: messageData['senderId'] ?? '',
          senderName: messageData['senderName'] ?? 'Usuário',
          senderRole: messageData['data']?['senderRole'], // Mapear role geral do Firebase
          senderClanCustomRole: messageData['data']?['senderClanCustomRole'], // Mapear cargo customizado do Firebase
          message: messageData['message'] ?? '',
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            messageData['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
          ), // Usar createdAt em vez de timestamp
          type: messageData['data']?['type'] ?? 'text',
          fileUrl: messageData['data']?['fileUrl'],
        );
      }).toList();

      // Ordenar por createdAt
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Atualizar cache local
      String cacheKey = chatType == 'global' ? 'global' : entityId;
      _messages[cacheKey] = messages;
      
      return messages;
    });
  }

  // Get cached messages for a specific channel
  List<Message> getCachedMessagesForEntity(String entityId) {
    return _messages[entityId] ?? [];
  }

  Future<void> atualizarStatusPresenca(String userId, bool isOnline) async {
    try {
      await _apiService.put(
        '/api/users/$userId/status',
        {'isOnline': isOnline},
        requireAuth: true,
      );
      Logger.info('User $userId presence updated to $isOnline');
    } catch (e) {
      Logger.error('Error updating user presence: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    Logger.info("Disposing ChatService.");
    super.dispose();
  }
}
