import 'package:invoiceapp/services/invoice_service.dart';
import 'package:invoiceapp/services/item_service.dart';
import 'package:invoiceapp/services/template_service.dart';
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
  final String _columnPaymentInstructions = 'paymentInstructions';
  final String _columnCompanyLogoUrl = 'company_logo_url';
  final String _columnWebsite = 'website';
  final String _columnState = 'state';
  final String _columnNote = 'note';

  static Database? _database;

  DatabaseService._constructor();

  Future<Database> getdatabase() async {
    if (_database != null) return _database!;

    final databaseDirpath = await getDatabasesPath();
    final databasepath = join(databaseDirpath, 'master_db.db');
    print("Database path: $databasepath");

    _database = await openDatabase(
      databasepath,
      version:
          6, // Incremented version to trigger include_image_in_pdf migration
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
            $_columnPaymentInstructions TEXT,
            $_columnCompanyLogoUrl TEXT,
            $_columnWebsite TEXT,
            $_columnState TEXT
          )
        ''');
        print("User table created successfully.");

        await ClientService.createClientTable(db);
        await ItemService.createItemTable(db);
        await InvoiceService.createInvoiceTables(db);
        await TemplateService.createTemplateTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await ClientService.createClientTable(db);
          await ItemService.createItemTable(db);
          await InvoiceService.createInvoiceTables(db);
        }
        if (oldVersion < 3) {
          await TemplateService.createTemplateTable(db);
        }
        if (oldVersion < 4) {
          // Add discount columns to existing item table
          try {
            await db.execute(
                'ALTER TABLE item ADD COLUMN discount_percentage REAL DEFAULT 0.0');
            await db.execute(
                'ALTER TABLE item ADD COLUMN discount_amount REAL DEFAULT 0.0');
            print("Added discount columns to item table.");
          } catch (e) {
            print("Error adding discount columns: $e");
          }
        }
        if (oldVersion < 5) {
          // Ensure discount columns exist (in case previous migration failed)
          try {
            await db.execute(
                'ALTER TABLE item ADD COLUMN discount_percentage REAL DEFAULT 0.0');
            print("Added discount_percentage column to item table.");
          } catch (e) {
            print("discount_percentage column may already exist: $e");
          }
          try {
            await db.execute(
                'ALTER TABLE item ADD COLUMN discount_amount REAL DEFAULT 0.0');
            print("Added discount_amount column to item table.");
          } catch (e) {
            print("discount_amount column may already exist: $e");
          }
        }
        if (oldVersion < 6) {
          // Add include_image_in_pdf column to item table
          try {
            await db.execute(
                'ALTER TABLE item ADD COLUMN include_image_in_pdf INTEGER DEFAULT 0');
            print("Added include_image_in_pdf column to item table.");
          } catch (e) {
            print("include_image_in_pdf column may already exist: $e");
          }
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
    String? note, // <-- Keep this
    String? paymentInstructions, // <-- Add this
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
        if (paymentInstructions != null)
          _columnPaymentInstructions:
              paymentInstructions, // <-- Update paymentInstructions
      },
      where: '$_columnId = ?',
      whereArgs: [userId],
    );
    print("User updated successfully.");
  }

  // Emergency method to reset database if migration fails
  static Future<void> resetDatabase() async {
    final databaseDirpath = await getDatabasesPath();
    final databasepath = join(databaseDirpath, 'master_db.db');

    try {
      await deleteDatabase(databasepath);
      print("Database deleted successfully.");
      _database = null; // Reset the database instance
    } catch (e) {
      print("Error deleting database: $e");
    }
  }
}
