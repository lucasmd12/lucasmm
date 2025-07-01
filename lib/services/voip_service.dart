import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';
import '../models/call_model.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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
      await _requestPermissions();
      _setupJitsiListeners();
      Logger.info("VoIP Service initialized successfully");
    } catch (e, stackTrace) {
      Logger.error("Failed to initialize VoIP Service", error: e, stackTrace: stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
      throw Exception("Falha ao inicializar serviço de VoIP: $e");
    }
  }

  // Solicitar permissões
  Future<void> _requestPermissions() async {
    final permissions = [Permission.camera, Permission.microphone];
    for (final permission in permissions) {
      final status = await permission.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Permissão ${permission.toString()} não concedida');
      }
    }
  }

  void _setupJitsiListeners() {
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
      if (_isInCall) throw Exception('Já existe uma chamada em andamento');

      _currentRoomId = roomId;

      final options = JitsiMeetConferenceOptions(
        serverURL: serverUrl ?? 'https://meet.jit.si',
        room: roomId,
        token: token,
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
        userInfo: JitsiMeetUserInfo(displayName: displayName),
      );

      await _jitsiMeet.join(options);
      _isInCall = true;
      _onCallStarted?.call(roomId);
      notifyListeners();
      Logger.info("Voice call started for room: $roomId");
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

  // Entrar manualmente numa reunião Jitsi
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
        token: password,
        configOverrides: {
          'startWithVideoMuted': false,
          'startWithAudioMuted': false,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: userDisplayName,
          avatar: userAvatarUrl,
        ),
      );

      await _jitsiMeet.join(options);
      _isInCall = true;
      _currentRoomId = roomName;
      notifyListeners();
      Logger.info("Joined Jitsi meeting: $roomName");
    } catch (error, stackTrace) {
      Logger.error('Erro ao entrar na reunião Jitsi: $error');
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
      rethrow;
    }
  }

  // Encerrar chamada
  Future<void> endCall() async {
    try {
      if (_isInCall) {
        await _jitsiMeet.hangUp();
        Logger.info('Call ended');
        _onCallEnded?.call(_currentRoomId ?? '');
      }
    } catch (e) {
      Logger.error('Failed to end call: $e');
    } finally {
      _isInCall = false;
      _currentRoomId = null;
      notifyListeners();
    }
  }

  // Gerar ID único
  static String generateRoomId({required String prefix, String? entityId}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return entityId != null ? '${prefix}_${entityId}_$random' : '${prefix}_$random';
  }

  // Validar nome de sala
  static bool isValidRoomName(String roomName) {
    final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
    return regex.hasMatch(roomName) && roomName.length >= 3 && roomName.length <= 50;
  }

  // Simular dados
  Call? currentCall;
  bool isCalling = false;
  Function(String)? onCallStateChanged;

  // Toggle mute
  void toggleMute() {
    Logger.info('Toggle mute');
  }

  Future<void> toggleAudio() async {
    try {
      Logger.info('Toggle audio');
    } catch (e) {
      Logger.error('Failed to toggle audio: $e');
      rethrow;
    }
  }

  Future<void> toggleVideo() async {
    try {
      Logger.info('Toggle video');
    } catch (e) {
      Logger.error('Failed to toggle video: $e');
      rethrow;
    }
  }

  Future<void> switchCamera() async {
    Logger.info('Switching camera');
  }

  // Simular chamadas
  Future<bool> initiateCall(String contactId, String contactName) async {
    return true;
  }

  Future<void> acceptCall(String callId, String roomName) async {
    Logger.info('Chamada $callId aceita. Entrando na sala $roomName');
  }

  Future<void> rejectCall(String callId) async {
    Logger.info('Chamada $callId rejeitada.');
  }

  Future<List<dynamic>> getCallHistory() async {
    return [];
  }

  String formatCallDuration() {
    return '00:00';
  }

  @override
  void dispose() {
    _isInCall = false;
    _currentRoomId = null;
    _onCallEnded = null;
    _onCallStarted = null;
    Logger.info('VoIP service disposed');
    super.dispose();
  }
}
