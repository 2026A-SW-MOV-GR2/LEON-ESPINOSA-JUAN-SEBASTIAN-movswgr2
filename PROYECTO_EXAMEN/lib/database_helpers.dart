import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

// --- SQLITE HELPER (Relacional) ---
class SqliteHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'products.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            subtitle TEXT,
            active INTEGER,
            date TEXT,
            iconCode INTEGER
          )
        ''');
      },
    );
  }

  static Future<int> insert(Map<String, dynamic> item) async {
    final db = await database;
    return await db.insert('items', {
      'title': item['title'],
      'subtitle': item['subtitle'],
      'active': item['active'] ? 1 : 0,
      'date': item['date'] is DateTime 
          ? (item['date'] as DateTime).toIso8601String() 
          : item['date']?.toString(),
      'iconCode': item['iconCode'],
    });
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    return maps.map((m) => {
      'id': m['id'],
      'title': m['title'],
      'subtitle': m['subtitle'],
      'active': m['active'] == 1,
      'date': m['date'] != null ? DateTime.tryParse(m['date'].toString()) : null,
      'iconCode': m['iconCode'],
    }).toList();
  }

  static Future<int> update(Map<String, dynamic> item) async {
    final db = await database;
    return await db.update(
      'items',
      {
        'title': item['title'],
        'subtitle': item['subtitle'],
        'active': item['active'] ? 1 : 0,
        'date': item['date'] is DateTime 
            ? (item['date'] as DateTime).toIso8601String() 
            : item['date']?.toString(),
        'iconCode': item['iconCode'],
      },
      where: 'id = ?',
      whereArgs: [item['id']],
    );
  }

  static Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }
}

// --- HIVE HELPER (NoSQL) ---
class HiveHelper {
  static const String boxName = 'itemsBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(boxName);
  }

  static Box<Map> get _box => Hive.box<Map>(boxName);

  static Future<void> insert(Map<String, dynamic> item) async {
    try {
      // 1. Preparamos el mapa sin el ID (Hive lo generará)
      final Map<String, dynamic> dataToSave = {
        'title': item['title'],
        'subtitle': item['subtitle'],
        'active': item['active'],
        'iconCode': item['iconCode'],
        // Convertimos la fecha a String explícitamente
        'date': item['date'] is DateTime
            ? (item['date'] as DateTime).toIso8601String()
            : item['date']?.toString(),
      };

      // 2. Usamos .add() para obtener un ID auto-incremental válido (0 - 0xFFFFFFFF)
      final int key = await _box.add(dataToSave);

      // 3. Sincronizamos el ID dentro del mapa para que el resto de la app funcione
      dataToSave['id'] = key;
      await _box.put(key, dataToSave);

      debugPrint('NoSQL (Hive) -> Insertado exitosamente con ID: $key');
    } catch (e) {
      debugPrint('NoSQL (Hive) -> Error al insertar: $e');
    }
  }

  static List<Map<String, dynamic>> getAll() {
    try {
      final items = _box.values.map((e) {
        final map = Map<String, dynamic>.from(e);
        
        // RECONSTRUIR: Pasamos de String a DateTime para que el formulario lo entienda
        if (map['date'] != null && map['date'] is String) {
          map['date'] = DateTime.tryParse(map['date']);
        }
        return map;
      }).toList();

      // Ordenar por ID descendente (más nuevos arriba)
      items.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
      debugPrint('NoSQL (Hive) -> Registros cargados: ${items.length}');
      return items;
    } catch (e) {
      debugPrint('NoSQL (Hive) -> Error al leer: $e');
      return [];
    }
  }

  static Future<void> update(Map<String, dynamic> item) async {
    try {
      final Map<String, dynamic> dataToUpdate = {
        'id': item['id'],
        'title': item['title'],
        'subtitle': item['subtitle'],
        'active': item['active'],
        'iconCode': item['iconCode'],
        'date': item['date'] is DateTime 
            ? (item['date'] as DateTime).toIso8601String() 
            : item['date']?.toString(),
      };
      await _box.put(item['id'], dataToUpdate);
      debugPrint('NoSQL (Hive) -> Actualizado exitosamente');
    } catch (e) {
      debugPrint('NoSQL (Hive) -> Error al actualizar: $e');
    }
  }

  static Future<void> delete(dynamic id) async {
    await _box.delete(id);
    debugPrint('NoSQL (Hive) -> Eliminado ID: $id');
  }

  static Future<void> clear() async {
    await _box.clear();
  }
}
