import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';
import '../models/call_model.dart';

class VoIPService extends ChangeNotifier {
  static final VoIPService _instance = VoIPService._internal();
  factory VoIPService() => _instance;
  VoIPService._internal();

  final JitsiMeet _jitsiMeet = JitsiMeet();
  bool _isInCall = false;
  String? _currentRoomId;
  Function(String)? _onCallEnded;
  Function(String)? _onCallStarted;

  bool get isInCall => _isInCall;
  String? get currentRoomId => _currentRoomId;

  // Configurar callbacks
  void setCallbacks({
    Function(String)? onCallEnded,
    Function(String)? onCallStarted,
  }) {
    _onCallEnded = onCallEnded;
    _onCallStarted = onCallStarted;
  }

  // Inicializar o serviço
  Future<void> initialize() async {
    try {
      // Solicitar permissões necessárias
      await _requestPermissions();
      
      // Configurar listeners do Jitsi
      _setupJitsiListeners();
      
      Logger.info('VoIP Service initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize VoIP Service: $e');
      throw Exception('Falha ao inicializar serviço de VoIP: $e');
    }
  }

  // Solicitar permissões necessárias
  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
    ];

    for (final permission in permissions) {
      final status = await permission.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Permissão ${permission.toString()} não concedida');
      }
    }
  }

  // Configurar listeners do Jitsi
  void _setupJitsiListeners() {
    // Nota: JitsiMeet v10.2.0 não usa addListener da mesma forma
    // Os eventos são tratados através de callbacks nos métodos join
    Logger.info('Jitsi listeners configured');
  }

  // Iniciar chamada de voz
  Future<void> startVoiceCall({
    required String roomId,
    required String displayName,
    String? serverUrl,
    String? token,
    bool isAudioOnly = true,
  }) async {
    try {
      if (_isInCall) {
        throw Exception('Já existe uma chamada em andamento');
      }

      _currentRoomId = roomId;

      final options = JitsiMeetConferenceOptions(
        serverURL: serverUrl ?? 'https://meet.jit.si',
        room: roomId,
        token: token, // Passando o token diretamente aqui
        configOverrides: {
          'startWithAudioMuted': false,
          'startWithVideoMuted': isAudioOnly,
          'requireDisplayName': true,
          'enableWelcomePage': false,
          'enableClosePage': false,
          'prejoinPageEnabled': false,
          'enableInsecureRoomNameWarning': false,
          'toolbarButtons': [
            'microphone',
            if (!isAudioOnly) 'camera',
            'hangup',
            'chat',
            'participants-pane',
            'settings',
          ],
        },
        featureFlags: {
          'unsaferoomwarning.enabled': false,
          'security-options.enabled': false,
          'invite.enabled': false,
          'meeting-name.enabled': false,
          'calendar.enabled': false,
          'recording.enabled': false,
          'live-streaming.enabled': false,
          'tile-view.enabled': true,
          'pip.enabled': true,
          'toolbox.alwaysVisible': false,
          'filmstrip.enabled': true,
          'add-people.enabled': false,
          'server-url-change.enabled': false,
          'chat.enabled': true,
          'raise-hand.enabled': true,
          'kick-out.enabled': false,
          'lobby-mode.enabled': false,
          'notifications.enabled': true,
          'meeting-password.enabled': false,
          'close-captions.enabled': false,
          'reactions.enabled': true,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: displayName,
        ),
      );

      await _jitsiMeet.join(options);
      
      Logger.info("Voice call started for room: $roomId");
      notifyListeners();
    } catch (e) {
      _currentRoomId = null;
      Logger.error('Failed to start voice call: $e');
      throw Exception('Falha ao iniciar chamada de voz: $e');
    }
  }

  // Iniciar chamada de vídeo
  Future<void> startVideoCall({
    required String roomId,
    required String displayName,
    String? serverUrl,
    String? token,
  }) async {
    await startVoiceCall(
      roomId: roomId,
      displayName: displayName,
      serverUrl: serverUrl,
      token: token,
      isAudioOnly: false,
    );
  }

  // Encerrar chamada
  Future<void> endCall() async {
    try {
      if (_isInCall) {
        await _jitsiMeet.hangUp();
        Logger.info('Call ended');
      }
    } catch (e) {
      Logger.error('Failed to end call: $e');
    } finally {
      _isInCall = false;
      _currentRoomId = null;
    }
  }

  // Gerar ID único para sala
  static String generateRoomId({
    required String prefix,
    String? entityId,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    
    if (entityId != null) {
      return '${prefix}_${entityId}_$random';
    } else {
      return '${prefix}_$random';
    }
  }

  // Validar nome da sala
  static bool isValidRoomName(String roomName) {
    // Jitsi Meet room names should be alphanumeric with hyphens and underscores
    final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
    return regex.hasMatch(roomName) && roomName.length >= 3 && roomName.length <= 50;
  }

  // Limpar recursos
  @override
  void dispose() {
    // Nota: removeAllListeners não existe na v10.2.0
    // Os listeners são gerenciados automaticamente
    _isInCall = false;
    _currentRoomId = null;
    _onCallEnded = null;
    _onCallStarted = null;
    Logger.info('VoIP service disposed');
    super.dispose();
  }

  // Adicionar métodos para aceitar/rejeitar/iniciar chamada
  Future<bool> initiateCall(String contactId, String contactName) async {
    // Lógica para iniciar a chamada (ex: notificar o backend, etc.)
    // Por enquanto, apenas simula o sucesso
    return true;
  }

  Future<void> acceptCall(String callId, String roomName) async {
    // Lógica para aceitar a chamada
    // Por enquanto, apenas simula
    Logger.info('Chamada $callId aceita. Entrando na sala $roomName');
  }

  Future<void> rejectCall(String callId) async {
    // Lógica para rejeitar a chamada
    // Por enquanto, apenas simula
    Logger.info('Chamada $callId rejeitada.');
  }

  Future<List<dynamic>> getCallHistory() async {
    // Lógica para obter histórico de chamadas
    // Por enquanto, retorna uma lista vazia
    return [];
  }

  // Método para formatar a duração da chamada (exemplo)
  String formatCallDuration() {
    // Implementar lógica real de duração da chamada
    return '00:00';
  }

  // Método para juntar a reunião Jitsi
  Future<void> joinJitsiMeeting({
    required String roomName,
    required String userDisplayName,
    String? userAvatarUrl,
    String? password,
  }) async {
    try {
      final options = JitsiMeetConferenceOptions(
        serverURL: 'https://meet.jit.si',
        room: roomName,
        token: password, // Passando o password (token) diretamente aqui
        configOverrides: {
          'startWithVideoMuted': false,
          'startWithAudioMuted': false,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: userDisplayName,
          avatar: userAvatarUrl, // Adicionado userAvatarUrl
        ),
      );

      await _jitsiMeet.join(options);
      _isInCall = true;
      _currentRoomId = roomName;
      notifyListeners();
    } catch (error) {
      Logger.error('Erro ao entrar na reunião Jitsi: $error');
      rethrow;
    }
  }

  // Propriedade para simular o estado da chamada
  Call? currentCall;

  // Propriedade para simular se está chamando
  bool isCalling = false;

  // Callback para mudança de estado da chamada
  Function(String)? onCallStateChanged;

  // Método para alternar o mudo
  void toggleMute() {
    // Implementar lógica real de mute
    Logger.info('Toggle mute');
  }

  // Método para alternar o áudio
  Future<void> toggleAudio() async {
    try {
      // Lógica para alternar o áudio via Jitsi Meet SDK
      // Exemplo: await _jitsiMeet.setAudioMuted(!_isMuted);
      Logger.info('Toggle audio');
    } catch (e) {
      Logger.error('Failed to toggle audio: $e');
      rethrow;
    }
  }

  // Método para alternar o vídeo
  Future<void> toggleVideo() async {
    try {
      // Lógica para alternar o vídeo via Jitsi Meet SDK
      // Exemplo: await _jitsiMeet.setVideoMuted(!_isVideoEnabled);
      Logger.info('Toggle video');
    } catch (e) {
      Logger.error('Failed to toggle video: $e');
      rethrow;
    }
  }

  // Método para alternar a câmera
  Future<void> switchCamera() async {
    // Implementar lógica real de troca de câmera
    Logger.info('Switching camera');
  }
}


