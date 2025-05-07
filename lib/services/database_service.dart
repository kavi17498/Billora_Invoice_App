import 'package:invoiceapp/services/item_service.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'client_service.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();

  final String _userTableName = 'user';
  final String _columnId = 'id';
  final String _columnName = 'name';
  final String _columnEmail = 'email';
  final String _columnPhone = 'phone';
  final String _columnAddress = 'address';
  final String _columnNote = 'note';
  final String _columnCompanyLogoUrl = 'company_logo_url';
  final String _columnWebsite = 'website';
  final String _columnState = 'state';

  static Database? _database;

  DatabaseService._constructor();

  Future<Database> getdatabase() async {
    if (_database != null) return _database!;

    final databaseDirpath = await getDatabasesPath();
    final databasepath = join(databaseDirpath, 'master_db.db');
    print("Database path: $databasepath");

    _database = await openDatabase(
      databasepath,
      version: 2, // Incremented version to allow table creation in onUpgrade
      onCreate: (db, version) async {
        print("Creating user table...");
        await db.execute('''
          CREATE TABLE $_userTableName (
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
        print("User table created successfully.");

        await ClientService.createClientTable(db);
        await ItemService.createItemTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await ClientService.createClientTable(db);
          await ItemService.createItemTable(db);
        }
      },
    );

    print("Database opened.");
    return _database!;
  }

  Future<void> insertUser(String content) async {
    final db = await getdatabase();
    await db.insert(_userTableName, {
      _columnName: content,
    });
    print("User inserted successfully.");
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await getdatabase();
    final result = await db.query(
      _userTableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> doesUserExist() async {
    final db = await getdatabase();
    final result = await db.query(_userTableName, limit: 1);
    return result.isNotEmpty;
  }

  Future<void> updateUserDetails({
    required int userId,
    String? address,
    String? phone,
    String? website,
    String? email,
    String? companyLogoUrl,
  }) async {
    final db = await getdatabase();
    await db.update(
      _userTableName,
      {
        if (address != null) _columnAddress: address,
        if (phone != null) _columnPhone: phone,
        if (website != null) _columnWebsite: website,
        if (email != null) _columnEmail: email,
        if (companyLogoUrl != null) _columnCompanyLogoUrl: companyLogoUrl,
      },
      where: '$_columnId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateallUserDetails({
    required int userId,
    String? address,
    String? phone,
    String? website,
    String? email,
    String? name, // <-- Add this
    String? note, // <-- And this
  }) async {
    final db = await getdatabase();
    await db.update(
      _userTableName,
      {
        if (address != null) _columnAddress: address,
        if (phone != null) _columnPhone: phone,
        if (website != null) _columnWebsite: website,
        if (email != null) _columnEmail: email,
        if (name != null) _columnName: name, // <-- Update name
        if (note != null) _columnNote: note, // <-- Update note
      },
      where: '$_columnId = ?',
      whereArgs: [userId],
    );
    print("User updated successfully.");
  }
}
