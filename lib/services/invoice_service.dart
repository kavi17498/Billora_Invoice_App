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

// Fixed getItemsForInvoice method for invoice_service.dart

  Future<Map<Item, int>> getItemsForInvoice(int invoiceId) async {
    final db = await DatabaseService.instance.getdatabase();
    final Map<Item, int> selectedItems = {};

    try {
      final result = await db.rawQuery('''
      SELECT ii.quantity, i.*
      FROM invoice_items ii
      JOIN item i ON ii.item_id = i.id
      WHERE ii.invoice_id = ?
    ''', [invoiceId]);

      for (var row in result) {
        // Handle null values carefully
        final id = row['id'];
        final name = row['name'];
        final description = row['description'];
        final price = row['price'];
        final cost = row['cost'];
        final imagePath = row['image_path'];
        final type = row['type'];
        final quantity = row['quantity'];

        // Skip this item if essential fields are null
        if (id == null || name == null || type == null || price == null) {
          print(
              'Warning: Found item with null essential fields for invoice $invoiceId');
          continue;
        }

        // Create item with proper null checks and type conversions
        final item = Item(
          id: id as int,
          name: name as String,
          description: description as String? ?? '',
          price: price is int ? (price as int).toDouble() : price as double,
          cost:
              cost is int ? (cost as int).toDouble() : (cost as double?) ?? 0.0,
          imagePath: imagePath as String? ?? '',
          type: type as String,
          // Handle quantity field for the Item object separately from the invoice quantity
          quantity: null, // Default to null since this is the item definition
        );

        // Handle invoice item quantity, defaulting to 1 for services as you mentioned
        int itemQuantity;
        if (quantity == null) {
          // If quantity is null, use 1 as default for services and 0 for goods
          itemQuantity = (type.toLowerCase() == 'service') ? 1 : 0;
          print(
              'Warning: Null quantity found for item ${item.name}, defaulting to $itemQuantity');
        } else {
          itemQuantity = quantity as int;
        }

        selectedItems[item] = itemQuantity;
      }

      return selectedItems;
    } catch (e) {
      print('Error fetching items for invoice: $e');
      return {};
    }
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
