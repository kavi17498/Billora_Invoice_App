import 'dart:io';
import 'package:flutter/material.dart';
import 'package:invoiceapp/services/item_service.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({Key? key}) : super(key: key);

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  List<Item> items = [];

  Future<void> _loadItems() async {
    final data = await ItemService.getAllItems();
    setState(() => items = data);
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: items.isEmpty
          ? const Center(child: Text("No items yet."))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, index) {
                final item = items[index];
                return ListTile(
                  leading: item.imagePath.isNotEmpty
                      ? Image.file(File(item.imagePath),
                          width: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image),
                  title: Text(item.name),
                  subtitle: Text(item.type),
                  trailing: item.type == 'good'
                      ? Text("Qty: ${item.quantity ?? 0}")
                      : null,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/create');
          _loadItems(); // Refresh after returning
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
