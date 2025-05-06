import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/client/client_details.dart';
import 'package:invoiceapp/services/client_service.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({Key? key}) : super(key: key);

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  List<Map<String, dynamic>> _clients = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final clients = await ClientService.getAllClients();
    setState(() {
      _clients = clients;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clients")),
      body: _clients.isEmpty
          ? const Center(child: Text("No clients found."))
          : ListView.builder(
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                final client = _clients[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(client['name'] ?? 'No Name'),
                  subtitle: Text(client['email'] ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ClientDetailsScreen(clientId: client['id']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
