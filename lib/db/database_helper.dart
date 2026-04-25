import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'stock.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {

        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price REAL,
            quantity INTEGER
          )
        ''');
      },
    );
  }

  // 🟢 تسجيل مستخدم جديد (Register)
  Future<void> insertUser(String email, String password) async {
    final dbClient = await db;

    await dbClient.insert(
      'users',
      {
        'email': email,
        'password': password,
      },
    );
  }

  // 🟢 تسجيل الدخول (Login)
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final dbClient = await db;

    List<Map<String, dynamic>> result = await dbClient.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}