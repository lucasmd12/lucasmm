import 'package:flutter/material.dart';
import 'package:lucasbeatsfederacao/models/clan_model.dart';
import 'package:lucasbeatsfederacao/screens/clan_text_chat_screen.dart';
import 'package:lucasbeatsfederacao/screens/instaclan_feed_widget.dart'; // Importar o novo widget

class ClanDetailScreen extends StatefulWidget {
  final Clan clan;

  const ClanDetailScreen({super.key, required this.clan});

  @override
  State<ClanDetailScreen> createState() => _ClanDetailScreenState();
}

class _ClanDetailScreenState extends State<ClanDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clan.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Descrição: ${widget.clan.description}'),
                Text('Membros: ${widget.clan.members?.length ?? 0}'),
                // Adicione mais detalhes do clã aqui
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClanTextChatScreen(clanId: widget.clan.id, clanName: widget.clan.name),
                      ),
                    );
                  },
                  child: const Text('Abrir Chat do Clã'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: InstaClanFeedWidget(clanId: widget.clan.id), // Adicionar o InstaClã Feed aqui
          ),
        ],
      ),
    );
  }
}


