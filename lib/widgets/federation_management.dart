import 'package:flutter/material.dart';
import 'package:lucasbeatsfederacao/models/user_model.dart';

class FederationManagement extends StatefulWidget {
  final UserModel currentUser;

  const FederationManagement({
    super.key,
    required this.currentUser,
  });

  @override
  State<FederationManagement> createState() => _FederationManagementState();
}

class _FederationManagementState extends State<FederationManagement> {
  final List<Map<String, dynamic>> _federations = [
    {
      'id': '1',
      'name': 'Elite Federation',
      'description': 'Federação dos melhores clãs',
      'clans': ['Warriors', 'Legends', 'Champions'],
      'totalMembers': 150,
      'createdAt': '2024-01-15',
    },
    {
      'id': '2',
      'name': 'Rising Stars',
      'description': 'Federação para clãs emergentes',
      'clans': ['Rookies', 'Newbies'],
      'totalMembers': 75,
      'createdAt': '2024-02-01',
    },
    {
      'id': '3',
      'name': 'Veterans Alliance',
      'description': 'Federação dos veteranos',
      'clans': ['Old Guard', 'Ancients', 'Masters'],
      'totalMembers': 200,
      'createdAt': '2024-01-01',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            children: [
              const Text(
                'Gerenciamento de Federações',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showCreateFederationDialog,
                icon: const Icon(Icons.add),
                label: const Text('Nova Federação'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Estatísticas das federações
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total de Federações',
                  _federations.length.toString(),
                  Icons.group_work,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total de Clãs',
                  _federations.fold<int>(0, (sum, fed) => sum + (fed['clans'] as List).length).toString(),
                  Icons.groups,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total de Membros',
                  _federations.fold<int>(0, (sum, fed) => sum + (fed['totalMembers'] as int)).toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Lista de federações
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _federations.length,
            itemBuilder: (context, index) {
              final federation = _federations[index];
              return _buildFederationCard(federation);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: Colors.grey.shade800.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFederationCard(Map<String, dynamic> federation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey.shade800.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da federação
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.group_work,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        federation['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        federation['description'],
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (action) => _handleFederationAction(action, federation),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'add_clan',
                      child: Row(
                        children: [
                          Icon(Icons.group_add, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Adicionar Clã'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'view_details',
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Ver Detalhes'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Estatísticas da federação
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFederationStat(
                    'Clãs',
                    (federation['clans'] as List).length.toString(),
                    Icons.groups,
                  ),
                  _buildFederationStat(
                    'Membros',
                    federation['totalMembers'].toString(),
                    Icons.people,
                  ),
                  _buildFederationStat(
                    'Criada em',
                    federation['createdAt'].toString().substring(0, 10),
                    Icons.calendar_today,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Lista de clãs
            const Text(
              'Clãs da Federação:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (federation['clans'] as List<String>).map((clan) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Text(
                    clan,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFederationStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  void _showCreateFederationDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Nova Federação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Federação',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _federations.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'clans': <String>[],
                    'totalMembers': 0,
                    'createdAt': DateTime.now().toString().substring(0, 10),
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Federação "${nameController.text}" criada com sucesso!')),
                );
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _handleFederationAction(String action, Map<String, dynamic> federation) {
    switch (action) {
      case 'edit':
        _editFederation(federation);
        break;
      case 'add_clan':
        _addClanToFederation(federation);
        break;
      case 'view_details':
        _viewFederationDetails(federation);
        break;
      case 'delete':
        _deleteFederation(federation);
        break;
    }
  }

  void _editFederation(Map<String, dynamic> federation) {
    final TextEditingController nameController = TextEditingController(text: federation['name']);
    final TextEditingController descriptionController = TextEditingController(text: federation['description']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Federação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Federação',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                federation['name'] = nameController.text;
                federation['description'] = descriptionController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Federação atualizada com sucesso!')),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _addClanToFederation(Map<String, dynamic> federation) {
    final TextEditingController clanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar Clã à ${federation['name']}'),
        content: TextField(
          controller: clanController,
          decoration: const InputDecoration(
            labelText: 'Nome do Clã',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (clanController.text.isNotEmpty) {
                setState(() {
                  (federation['clans'] as List<String>).add(clanController.text);
                  federation['totalMembers'] = (federation['totalMembers'] as int) + 25; // Mock
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Clã "${clanController.text}" adicionado à federação!')),
                );
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _viewFederationDetails(Map<String, dynamic> federation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalhes - ${federation['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${federation['name']}'),
            Text('Descrição: ${federation['description']}'),
            Text('Clãs: ${(federation['clans'] as List).length}'),
            Text('Membros: ${federation['totalMembers']}'),
            Text('Criada em: ${federation['createdAt']}'),
            const SizedBox(height: 12),
            const Text('Clãs da Federação:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...(federation['clans'] as List<String>).map((clan) => Text('• $clan')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _deleteFederation(Map<String, dynamic> federation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Federação'),
        content: Text('Tem certeza que deseja excluir a federação "${federation['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _federations.remove(federation);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Federação "${federation['name']}" excluída!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

