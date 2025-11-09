import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'product.dart';

class ProductDatabaseHelper {
  static Database? _database;
  static final ProductDatabaseHelper instance = ProductDatabaseHelper._privateConstructor();
  ProductDatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, 'fashion_store.db');

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      _database = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ),
      );
      // ignore: avoid_print
      print("✅ Using FFI-based SQLite factory for desktop.");
    } else {
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
      // ignore: avoid_print
      print("✅ Using default SQLite factory for mobile.");
    }

    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        price REAL,
        description TEXT,
        imageUrl TEXT
      )
    ''');
  }

  Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;
    final result = await db.query('products', orderBy: 'name ASC');
    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Optional: Add a method to get products by category for fashion store filtering
  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
    return result.map((e) => Product.fromMap(e)).toList();
  }
}