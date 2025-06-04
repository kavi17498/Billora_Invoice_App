import 'dart:io';
import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/items/edit_item.dart';
import 'package:invoiceapp/services/item_service.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

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
          ? const Center(child: Text("Create Your First Item..."))
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.type == 'good')
                        Text("Qty: ${item.quantity ?? 0}"),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditItemPage(itemId: item.id!),
                            ),
                          );
                          _loadItems(); // Refresh the list
                        },
                      ),
                    ],
                  ),
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
