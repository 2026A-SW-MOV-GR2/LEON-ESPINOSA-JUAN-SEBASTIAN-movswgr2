import 'package:flutter/foundation.dart';
import 'database_helpers.dart';

/// Abstracción común para aislar la interfaz gráfica del motor de datos.
abstract class ItemRepository {
  Future<void> insert(Map<String, dynamic> item);
  Future<List<Map<String, dynamic>>> getAll();
  Future<void> update(Map<String, dynamic> item);
  Future<void> delete(dynamic id);
}

class SqliteItemRepository implements ItemRepository {
  @override
  Future<void> insert(Map<String, dynamic> item) async {
    debugPrint('[INFO] SQLite: Insertando elemento: ${item['title']}');
    try {
      await SqliteHelper.insert(item);
      debugPrint('[DEBUG] SQLite: Inserción exitosa');
    } catch (e) {
      debugPrint('[ERROR] SQLite: Error al insertar: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    debugPrint('[INFO] SQLite: Consultando todos los elementos');
    return await SqliteHelper.getAll();
  }

  @override
  Future<void> update(Map<String, dynamic> item) async {
    debugPrint('[INFO] SQLite: Actualizando elemento ID: ${item['id']}');
    await SqliteHelper.update(item);
  }

  @override
  Future<void> delete(dynamic id) async {
    debugPrint('[INFO] SQLite: Eliminando elemento ID: $id');
    await SqliteHelper.delete(id);
  }
}

class HiveItemRepository implements ItemRepository {
  @override
  Future<void> insert(Map<String, dynamic> item) async {
    debugPrint('[INFO] Hive: Insertando elemento: ${item['title']}');
    try {
      await HiveHelper.insert(item);
      debugPrint('[DEBUG] Hive: Inserción exitosa');
    } catch (e) {
      debugPrint('[ERROR] Hive: Error al insertar: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    debugPrint('[INFO] Hive: Consultando todos los elementos');
    return HiveHelper.getAll();
  }

  @override
  Future<void> update(Map<String, dynamic> item) async {
    debugPrint('[INFO] Hive: Actualizando elemento ID: ${item['id']}');
    await HiveHelper.update(item);
  }

  @override
  Future<void> delete(dynamic id) async {
    debugPrint('[INFO] Hive: Eliminando elemento ID: $id');
    await HiveHelper.delete(id);
  }
}

/// Gestor que alterna entre repositorios según la configuración
class ProductService {
  ItemRepository _repository = SqliteItemRepository();
  bool _isSqlite = true;

  bool get isSqlite => _isSqlite;

  void useSqlite() {
    _isSqlite = true;
    _repository = SqliteItemRepository();
    debugPrint('[INFO] Sistema: Cambiando a motor RELACIONAL (SQLite)');
  }

  void useHive() {
    _isSqlite = false;
    _repository = HiveItemRepository();
    debugPrint('[INFO] Sistema: Cambiando a motor NO RELACIONAL (Hive)');
  }

  Future<void> addItem(Map<String, dynamic> item) => _repository.insert(item);
  Future<List<Map<String, dynamic>>> getItems() => _repository.getAll();
  Future<void> updateItem(Map<String, dynamic> item) => _repository.update(item);
  Future<void> deleteItem(dynamic id) => _repository.delete(id);
}
