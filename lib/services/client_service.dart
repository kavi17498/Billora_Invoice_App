import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class ClientService {
  static const String _clientTable = 'client';
  static const String _id = 'id';
  static const String _name = 'name';
  static const String _email = 'email';
  static const String _phone = 'phone';
  static const String _address = 'address';
  static const String _note = 'note';

  // Called from DatabaseService
  static Future<void> createClientTable(Database db) async {
    print("Creating client table...");
    await db.execute('''
      CREATE TABLE $_clientTable (
        $_id INTEGER PRIMARY KEY AUTOINCREMENT,
        $_name TEXT,
        $_email TEXT,
        $_phone TEXT,
        $_address TEXT,
        $_note TEXT
      )
    ''');
    print("Client table created.");
  }

  static Future<int> insertClient({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? note,
  }) async {
    final db = await DatabaseService.instance.getdatabase();
    final id = await db.insert(_clientTable, {
      _name: name,
      _email: email,
      _phone: phone,
      _address: address,
      _note: note,
    });
    print("Client inserted with ID: $id.");
    return id;
  }

  static Future<Map<String, dynamic>?> getClientById(int id) async {
    final db = await DatabaseService.instance.getdatabase();
    final result = await db.query(
      _clientTable,
      where: '$_id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<List<Map<String, dynamic>>> getAllClients() async {
    final db = await DatabaseService.instance.getdatabase();
    return await db.query(_clientTable);
  }

  static Future<void> updateClient({
    required int id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? note,
  }) async {
    final db = await DatabaseService.instance.getdatabase();
    await db.update(
      _clientTable,
      {
        if (name != null) _name: name,
        if (email != null) _email: email,
        if (phone != null) _phone: phone,
        if (address != null) _address: address,
        if (note != null) _note: note,
      },
      where: '$_id = ?',
      whereArgs: [id],
    );
    print("Client ID $id updated.");
  }

  static Future<void> deleteClient(int id) async {
    final db = await DatabaseService.instance.getdatabase();
    await db.delete(
      _clientTable,
      where: '$_id = ?',
      whereArgs: [id],
    );
    print("Client ID $id deleted.");
  }
}
