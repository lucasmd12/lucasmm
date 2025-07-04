import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lucasbeatsfederacao/providers/auth_provider.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';
import 'package:lucasbeatsfederacao/screens/tabs/home_tab.dart';
import 'package:lucasbeatsfederacao/screens/tabs/missions_tab.dart';
import 'package:lucasbeatsfederacao/screens/tabs/chat_list_tab.dart';
import 'package:lucasbeatsfederacao/screens/global_chat_screen.dart';
import 'package:lucasbeatsfederacao/screens/voice_rooms_screen.dart';
import 'package:lucasbeatsfederacao/screens/federation_list_screen.dart';
import 'package:lucasbeatsfederacao/screens/invite_list_screen.dart'; // Importar a tela de convites
import 'package:sentry_flutter/sentry_flutter.dart'; // Certifique-se de que esta importação está correta
// Import Crashlytics

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeTab(),
    // MembersTab() e SettingsTab() removidos daqui, pois são específicas do gerenciamento de clãs.
    ChatListTab(),
    GlobalChatScreen(),
    MissionsTab(),
    // Se houver uma tela de configurações geral, ela deve ser adicionada aqui.
  ];

  final List<String> _backgroundImages = [
    'assets/images_png/backgrounds/bg_mercedes_forest.png',
    'assets/images_png/backgrounds/bg_bmw_smoke_01.png',
    'assets/images_png/backgrounds/bg_joker_smoke.png',
    'assets/images_png/backgrounds/bg_cards_dice.png',
    'assets/images_png/backgrounds/bg_audi_autumn.png',
    'assets/images_png/backgrounds/bg_mustang_autumn.png',
    'assets/images_png/backgrounds/bg_gtr_night.png',
    'assets/images_png/backgrounds/bg_bmw_smoke_02.png',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
    });
  }

  Future<void> _requestPermissions() async {
    final transaction = Sentry.startTransaction(
      'requestPermissions',
      'permission_request',
      description: 'Requesting necessary permissions',
    );
    Logger.info("Requesting necessary permissions...");
    try {
      final notificationSpan = transaction.startChild(
        'requestNotificationPermission',
        description: 'Requesting notification permission',
      );
      PermissionStatus notificationStatus = await Permission.notification.request();
      // CORREÇÃO AQUI: SentrySpanStatus.ok() -> SpanStatus.ok()
      notificationSpan.finish(status: SpanStatus.ok());

      if (notificationStatus.isGranted) {
        Logger.info("Notification permission granted.");
      } else if (notificationStatus.isDenied) {
        Logger.warning("Notification permission denied.");
      } else if (notificationStatus.isPermanentlyDenied) {
        Logger.error("Notification permission permanently denied.");
        _showSettingsDialog("Notificações");
      }

      final storageSpan = transaction.startChild(
        'requestStoragePermission',
        description: 'Requesting storage permission',
      );
      PermissionStatus storageStatus = await Permission.storage.request();
      storageSpan.finish(status: SpanStatus.ok());

      if (storageStatus.isGranted) {
        Logger.info("Storage permission granted.");
      } else if (storageStatus.isDenied) {
        Logger.warning("Storage permission denied.");
      } else if (storageStatus.isPermanentlyDenied) {
        Logger.error("Storage permission permanently denied.");
        _showSettingsDialog("Armazenamento");
      }

      final microphoneSpan = transaction.startChild(
        'requestMicrophonePermission',
        description: 'Requesting microphone permission',
      );
      PermissionStatus microphoneStatus = await Permission.microphone.request();
      microphoneSpan.finish(status: SpanStatus.ok());

      if (microphoneStatus.isGranted) {
        Logger.info("Microphone permission granted.");
      } else if (microphoneStatus.isDenied) {
        Logger.warning("Microphone permission denied.");
      } else if (microphoneStatus.isPermanentlyDenied) {
        Logger.error("Microphone permission permanently denied.");
        _showSettingsDialog("Microfone");
      }
      // CORREÇÃO AQUI: SentrySpanStatus.ok() -> SpanStatus.ok()
      transaction.finish(status: SpanStatus.ok());
    } catch (e, stackTrace) {
      // CORREÇÃO AQUI: SentrySpanStatus.internalError() -> SpanStatus.internalError()
      transaction.finish(status: SpanStatus.internalError());
      Sentry.captureException(e, stackTrace: stackTrace);
      Logger.error("Error requesting permissions", error: e, stackTrace: stackTrace);
    }
  }

  void _showSettingsDialog(String permissionName) {
     if (!mounted) return;
     showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Permissão Necessária"),
          content: Text("A permissão de $permissionName foi negada permanentemente. Por favor, habilite-a nas configurações do aplicativo para usar todas as funcionalidades."),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Abrir Configurações"),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Logger.info("Switched to tab index: $index");
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final textTheme = Theme.of(context).textTheme;

    if (authProvider.authStatus == AuthStatus.unknown) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
             valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
      );
    }

    if (currentUser == null) {
       Logger.warning("HomeScreen build: User is null even though authenticated. This shouldn't happen.");
       return Scaffold(
         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
         body: Center(child: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Text("Erro crítico ao carregar dados do usuário. Por favor, tente reiniciar o aplicativo.", textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: Colors.white)),
         )),
       );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              currentUser.username,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [

          IconButton(
            icon: const Icon(Icons.account_tree),
            tooltip: 'Federações',
            onPressed: () {
              Logger.info("Federations button pressed.");
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FederationListScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.record_voice_over),
            tooltip: 'Salas de Voz',
            onPressed: () {
              Logger.info("Voice rooms button pressed.");
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VoiceRoomsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notificações',
            onPressed: () {
              Logger.info("Notifications button pressed.");
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const InviteListScreen(), // Navegar para a tela de convites
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_backgroundImages[_selectedIndex % _backgroundImages.length]),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: IndexedStack(
           index: _selectedIndex,
           children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Voz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public_outlined),
            activeIcon: Icon(Icons.public),
            label: 'Global',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Missões',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
