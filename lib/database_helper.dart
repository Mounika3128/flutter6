import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'clothing_item.dart';

class ClothingDatabaseHelper {
  static Database? _database;
  static final ClothingDatabaseHelper instance =
      ClothingDatabaseHelper._privateConstructor();
  ClothingDatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, 'clothing_store.db');

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      _database = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ),
      );
    } else {
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    }

    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clothing (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        brand TEXT,
        size TEXT
      )
    ''');
  }

  Future<int> insertClothing(ClothingItem item) async {
    final db = await instance.database;
    return await db.insert('clothing', item.toMap());
  }

  Future<List<ClothingItem>> getAllClothing() async {
    final db = await instance.database;
    final result = await db.query('clothing', orderBy: 'name ASC');
    return result.map((e) => ClothingItem.fromMap(e)).toList();
  }

  Future<int> updateClothing(ClothingItem item) async {
    final db = await instance.database;
    return await db.update(
      'clothing',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteClothing(int id) async {
    final db = await instance.database;
    return await db.delete(
      'clothing',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
