import 'package:invoiceapp/services/item_service.dart';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class InvoiceService {
  static const String _invoiceTable = 'invoice';
  static const String _invoiceItemsTable = 'invoice_items';
  static const String _id = 'id';
  static const String _invoiceid = 'invoice_id';
  static const String _invoiceNumber = 'invoice_number';
  static const String _billTo = 'bill_to';
  static const String _address = 'address';
  static const String _email = 'email';
  static const String _phone = 'phone';
  static const String _totalPrice = 'total_price';
  static const String _createdAt = 'created_at';
  static const String _itemId = 'item_id';
  static const String _quantity = 'quantity';

  static Future<void> createInvoiceTables(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $_invoiceTable (
      $_id INTEGER PRIMARY KEY AUTOINCREMENT,
      $_invoiceNumber TEXT,
      $_billTo TEXT,
      $_address TEXT,
      $_email TEXT,
      $_phone TEXT,
      $_totalPrice REAL,
      $_createdAt TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS $_invoiceItemsTable (
      $_id INTEGER PRIMARY KEY AUTOINCREMENT,
      $_invoiceid INTEGER,
      $_itemId INTEGER,
      $_quantity INTEGER,
      FOREIGN KEY($_invoiceid) REFERENCES invoice($_id),
      FOREIGN KEY($_itemId) REFERENCES item($_id)
    )
  ''');
  }

  Future<int> saveInvoice({
    required String invoiceNumber,
    required String billTo,
    required String address,
    required String email,
    required String phone,
    required double totalPrice,
    required Map<Item, int> selectedItems,
  }) async {
    final db = await DatabaseService.instance.getdatabase();

    final now = DateTime.now().toIso8601String();

    // Insert invoice
    final invoiceId = await db.insert('invoice', {
      'invoice_number': invoiceNumber,
      'bill_to': billTo,
      'address': address,
      'email': email,
      'phone': phone,
      'total_price': totalPrice,
      'created_at': now,
    });

    // Insert items for this invoice
    for (final entry in selectedItems.entries) {
      await db.insert('invoice_items', {
        'invoice_id': invoiceId,
        'item_id': entry.key.id, // Make sure Item has an id field
        'quantity': entry.value,
      });
    }

    return invoiceId;
  }

  Future<Map<Item, int>> getItemsForInvoice(int invoiceId) async {
    final db = await DatabaseService.instance.getdatabase();

    final result = await db.rawQuery('''
    SELECT ii.quantity, i.*
    FROM invoice_items ii
    JOIN item i ON ii.item_id = i.id
    WHERE ii.invoice_id = ?
  ''', [invoiceId]);

    Map<Item, int> selectedItems = {};

    for (var row in result) {
      final item = Item(
        id: row['id'] as int,
        name: row['name'] as String,
        description: row['description'] as String,
        price: row['price'] is int
            ? (row['price'] as int).toDouble()
            : row['price'] as double,
        cost: row['cost'] is int
            ? (row['cost'] as int).toDouble()
            : row['cost'] as double,
        imagePath: row['image_path'] as String,
        type: row['type'] as String,
        quantity: row['quantity'] as int?, // optional field
      );

      selectedItems[item] = row['quantity'] as int;
    }

    return selectedItems;
  }

  Future<List<Map<String, dynamic>>> getAllInvoices() async {
    final db = await DatabaseService.instance.getdatabase();

    final result = await db.query(
      _invoiceTable,
      orderBy: '$_createdAt DESC', // Optional: newest first
    );

    return result.map((row) {
      return {
        'id': row[_id],
        'invoice_number': row[_invoiceNumber],
        'bill_to': row[_billTo],
        'address': row[_address],
        'email': row[_email],
        'phone': row[_phone],
        'total': row[_totalPrice],
        'created_at': row[_createdAt],
      };
    }).toList();
  }
}
