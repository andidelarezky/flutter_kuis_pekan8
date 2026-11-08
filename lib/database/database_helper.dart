import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
      DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // Membuka database
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('kontak_telepon.db');

    return _database!;
  }

  // Inisialisasi database
  Future<Database> _initDB(String fileName) async {
    if (kIsWeb) {
      return await databaseFactoryFfiWeb.openDatabase(
        fileName,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDB,
        ),
      );
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Membuat tabel
  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL
      )
    ''');
  }

  // Menampilkan seluruh kontak
  Future<List<Map<String, dynamic>>> getContacts() async {
    final db = await instance.database;

    return await db.query(
      'contacts',
      orderBy: 'id DESC',
    );
  }

  // Menambahkan kontak
  Future<int> insertContact(
    Map<String, dynamic> data,
  ) async {
    final db = await instance.database;

    return await db.insert(
      'contacts',
      data,
    );
  }

  // Mengedit kontak
  Future<int> updateContact(
    int id,
    Map<String, dynamic> data,
  ) async {
    final db = await instance.database;

    return await db.update(
      'contacts',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menghapus kontak
  Future<int> deleteContact(int id) async {
    final db = await instance.database;

    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}