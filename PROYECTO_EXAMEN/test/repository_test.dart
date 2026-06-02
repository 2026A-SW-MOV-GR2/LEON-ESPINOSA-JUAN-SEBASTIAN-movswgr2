import 'package:flutter_test/flutter_test.dart';
import 'package:clase3/item_repository.dart';

void main() {
  group('ProductService Tests', () {
    late ProductService productService;

    setUp(() {
      productService = ProductService();
    });

    test('Debe iniciar con SQLite por defecto', () {
      expect(productService.isSqlite, true);
    });

    test('Debe cambiar a Hive correctamente', () {
      productService.useHive();
      expect(productService.isSqlite, false);
    });

    test('Debe volver a SQLite correctamente', () {
      productService.useHive();
      productService.useSqlite();
      expect(productService.isSqlite, true);
    });
  });
}
