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

  DatabaseService._constructor();

  Future<Database> getdatabase() async {
    final databaseDirpath = await getDatabasesPath();
    final databasepath = join(databaseDirpath, 'master_db.db');
    final database = await openDatabase(
      databasepath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $_tableName (
            $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_columnName TEXT ,
            $_columnEmail TEXT ,
            $_columnPhone TEXT ,
            $_columnAddress TEXT ,
            $_columnNote TEXT ,
          )
        ''');
      },
    );
    return database;
  }

  void insertUser(
    String content,
  ) async {
    final db = await getdatabase();
    await db.insert(_tableName, {
      _columnName: content,
      _columnEmail: content,
      _columnPhone: content,
      _columnAddress: content,
      _columnNote: content,
    });
  }
}
