import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucasbeatsfederacao/services/auth_service.dart';
import 'package:lucasbeatsfederacao/services/chat_service.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';
import 'package:lucasbeatsfederacao/models/user_model.dart';

class AppLifecycleReactor extends StatefulWidget {
  final Widget child;

  const AppLifecycleReactor({super.key, required this.child});

  @override
  State<AppLifecycleReactor> createState() => _AppLifecycleReactorState();
}

class _AppLifecycleReactorState extends State<AppLifecycleReactor> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Logger.info("AppLifecycleReactor initialized and observing.");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updatePresence(true);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Logger.info("App lifecycle state changed: $state");

    switch (state) {
      case AppLifecycleState.resumed:
        _updatePresence(true);
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        _updatePresence(false);
        break;
      case AppLifecycleState.detached:
        _updatePresence(false);
        break;
      case AppLifecycleState.hidden:
         _updatePresence(false);
         break;
    }
  }

  Future<void> _updatePresence(bool isOnline) async {
    if (!mounted) return;
    final authService = context.read<AuthService>();
    final chatService = context.read<ChatService>();
    final User? currentUser = authService.currentUser;

    if (currentUser != null) {
      final userId = currentUser.id;
      Logger.info("Updating presence for user $userId to: ${isOnline ? 'online' : 'offline'}");
      chatService.atualizarStatusPresenca(userId, isOnline).catchError((e, s) {
         Logger.error("Error updating presence in background", error: e, stackTrace: s);
      });
    } else {
       Logger.warning("Cannot update presence: currentUser is null when trying to update.");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Logger.info("AppLifecycleReactor disposed and stopped observing.");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}


