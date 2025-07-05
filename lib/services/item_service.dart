import 'package:sqflite/sqflite.dart';

import 'database_service.dart';
import 'currency_service.dart';

class Item {
  int? id;
  String name;
  String description;
  double price;
  double cost;
  String imagePath; // Local file path
  String type; // Always 'item' now - everything is an item
  int quantity; // Default quantity, always required
  double discountPercentage; // Discount percentage (0-100)
  double discountAmount; // Fixed discount amount
  bool includeImageInPdf; // Whether to include image in PDF generation

  Item({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.cost,
    required this.imagePath,
    this.type = 'item', // Default to 'item'
    this.quantity = 1, // Default quantity is 1
    this.discountPercentage = 0.0, // Default no discount
    this.discountAmount = 0.0, // Default no discount
    this.includeImageInPdf = false, // Default to not include image in PDF
  });

  // Calculate final price after discount
  double get finalPrice {
    if (discountAmount > 0) {
      // Fixed discount amount takes priority
      return (price - discountAmount).clamp(0.0, double.infinity);
    } else if (discountPercentage > 0) {
      // Apply percentage discount
      final discount = price * (discountPercentage / 100);
      return (price - discount).clamp(0.0, double.infinity);
    }
    return price;
  }

  // Get discount display text
  String get discountDisplay {
    if (discountAmount > 0) {
      return 'Fixed amount off';
    } else if (discountPercentage > 0) {
      return '${discountPercentage.toStringAsFixed(1)}% off';
    }
    return '';
  }

  // Method to get formatted discount display with currency
  Future<String> getDiscountDisplayWithCurrency() async {
    if (discountAmount > 0) {
      final currency = await CurrencyService.getCurrentCurrency();
      return '${currency.symbol} ${discountAmount.toStringAsFixed(2)} off';
    } else if (discountPercentage > 0) {
      return '${discountPercentage.toStringAsFixed(1)}% off';
    }
    return '';
  }

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
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'include_image_in_pdf': includeImageInPdf ? 1 : 0,
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
      discountPercentage: (map['discount_percentage'] ?? 0.0).toDouble(),
      discountAmount: (map['discount_amount'] ?? 0.0).toDouble(),
      includeImageInPdf: (map['include_image_in_pdf'] ?? 0) == 1,
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
        quantity INTEGER,
        discount_percentage REAL DEFAULT 0.0,
        discount_amount REAL DEFAULT 0.0,
        include_image_in_pdf INTEGER DEFAULT 0
      )
    ''');
    print("Item table created.");
  }

  // Migration method to add include_image_in_pdf column to existing tables
  static Future<void> migrateItemTable(Database db) async {
    try {
      // Check if the column already exists
      final result = await db.rawQuery("PRAGMA table_info($_itemTable)");
      bool columnExists =
          result.any((column) => column['name'] == 'include_image_in_pdf');

      if (!columnExists) {
        print("Adding include_image_in_pdf column to item table...");
        await db.execute('''
          ALTER TABLE $_itemTable ADD COLUMN include_image_in_pdf INTEGER DEFAULT 0
        ''');
        print("include_image_in_pdf column added to item table.");
      }
    } catch (e) {
      print("Error migrating item table: $e");
    }
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
