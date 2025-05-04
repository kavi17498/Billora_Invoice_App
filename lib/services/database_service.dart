import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tableName = 'user';
  final String _columnId = 'id';
  final String _columnName = 'name';
  final String _columnEmail = 'email';
  final String _columnPhone = 'phone';
  final String _columnAddress = 'address';
  final String _columnNote = 'note';
  final String _columnTaxprecent = 'tax_percent';
  final String _columnPassword = 'password';
  final String _columnCompanyName = 'company_name';
  final String _columnCompanyLogoUrl = 'company_logo_url';
  final String _columnWebsite = 'website';
  final String _columnState = 'state';

  DatabaseService._constructor();

  Future<Database> getdatabase() async {
    final databaseDirpath = await getDatabasesPath();
    final databasepath = join(databaseDirpath, 'master_db.db');
    print("Database path: $databasepath");

    final database = await openDatabase(
      databasepath,
      version: 1,
      onCreate: (db, version) async {
        print("Creating table $_tableName...");
        await db.execute('''
          CREATE TABLE $_tableName (
            $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_columnName TEXT,
            $_columnEmail TEXT,
            $_columnPhone TEXT,
            $_columnAddress TEXT,
            $_columnNote TEXT,
            $_columnCompanyLogoUrl TEXT,
            $_columnWebsite TEXT,
            $_columnState TEXT
          )
        ''');
        print("Table $_tableName created successfully.");
      },
    );

    print("Database opened.");
    return database;
  }

  Future<void> insertUser(String content) async {
    try {
      final db = await getdatabase();
      print("Inserting user with content: $content");

      await db.insert(_tableName, {
        _columnName: content,
      });

      print("User inserted successfully into $_tableName.");
    } catch (e) {
      print("Error inserting user: $e");
      rethrow;
    }
  }

  Future<void> updateUserDetails({
    required int userId,
    String? address,
    String? phone,
    String? website,
    String? email,
  }) async {
    try {
      final db = await getdatabase();
      await db.update(
        _tableName,
        {
          if (address != null) _columnAddress: address,
          if (phone != null) _columnPhone: phone,
          if (website != null) _columnWebsite: website,
          if (email != null) _columnEmail: email,
        },
        where: '$_columnId = ?',
        whereArgs: [userId],
      );
      print("User ID $userId updated successfully.");
    } catch (e) {
      print("Error updating user: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await getdatabase();
    final result = await db.query(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }
}
