import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class Item {
  int? id;
  String name;
  String description;
  double price;
  double cost;
  String imagePath; // Local file path
  String type; // Always 'item' now - everything is an item
  int quantity; // Default quantity, always required

  Item({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.cost,
    required this.imagePath,
    this.type = 'item', // Default to 'item'
    this.quantity = 1, // Default quantity is 1
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'cost': cost,
      'image_path': imagePath,
      'type': type,
      'quantity': quantity,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      cost: (map['cost'] ?? 0.0).toDouble(),
      imagePath: map['image_path'] ?? '',
      type: map['type'] ?? 'item',
      quantity: map['quantity'] ?? 1,
    );
  }
}

class ItemService {
  static const String _itemTable = 'item';

  // Create table
  static Future<void> createItemTable(Database db) async {
    print("Creating item table...");
    await db.execute('''
      CREATE TABLE $_itemTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        price REAL,
        cost REAL,
        image_path TEXT,
        type TEXT,
        quantity INTEGER
      )
    ''');
    print("Item table created.");
  }

  // Insert item
  static Future<int> insertItem(Item item) async {
    final db = await DatabaseService.instance.getdatabase();
    return await db.insert(_itemTable, item.toMap());
  }

  // Get all items
  static Future<List<Item>> getAllItems() async {
    final db = await DatabaseService.instance.getdatabase();
    final List<Map<String, dynamic>> maps = await db.query(_itemTable);
    return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
  }

  // Get item by ID
  static Future<Item?> getItemById(int id) async {
    final db = await DatabaseService.instance.getdatabase();
    final maps = await db.query(_itemTable, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Item.fromMap(maps.first);
    }
    return null;
  }

  // Update item
  static Future<int> updateItem(Item item) async {
    final db = await DatabaseService.instance.getdatabase();
    return await db.update(
      _itemTable,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete item
  static Future<int> deleteItem(int id) async {
    final db = await DatabaseService.instance.getdatabase();
    return await db.delete(
      _itemTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
