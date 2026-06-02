import 'package:flutter/material.dart';
import 'form_page.dart';
import 'native_toast.dart';
import 'network_page.dart';
import 'item_repository.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    final data = await _productService.getItems();
    setState(() {
      _items = data;
      _isLoading = false;
    });
  }

  final List<IconData> _availableIcons = [
    Icons.phone_android,
    Icons.laptop_mac,
    Icons.headphones,
    Icons.watch,
    Icons.camera_alt,
    Icons.tablet_mac,
    Icons.tv,
    Icons.keyboard,
    Icons.mouse,
    Icons.speaker,
  ];

  Future<void> _openForm({Map<String, dynamic>? item}) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => FormPage(item: item),
      ),
    );

    if (result != null) {
      if (item == null) {
        // New item
        result['iconCode'] = _availableIcons[_items.length % _availableIcons.length].codePoint;
        await _productService.addItem(result);
      } else {
        // Update item
        result['id'] = item['id'];
        result['iconCode'] = item['iconCode'];
        await _productService.updateItem(result);
      }
      _refreshData();
    }
  }

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Desea eliminar "${item['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _productService.deleteItem(item['id']);
      _refreshData();
      await NativeToast.show('${item['title']} eliminado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSqlite = _productService.isSqlite;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Dual DB'),
        backgroundColor: isSqlite ? Colors.blue.shade100 : Colors.orange.shade100,
        actions: [
          Row(
            children: [
              Text(isSqlite ? 'SQL' : 'NoSQL', 
                style: TextStyle(fontWeight: FontWeight.bold, color: isSqlite ? Colors.blue : Colors.orange)),
              Switch(
                value: isSqlite,
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      _productService.useSqlite();
                    } else {
                      _productService.useHive();
                    }
                  });
                  _refreshData();
                },
                activeColor: Colors.blue,
                inactiveThumbColor: Colors.orange,
                inactiveTrackColor: Colors.orange.withOpacity(0.5),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            tooltip: 'Gestión de Secretos',
          ),
          IconButton(
            icon: const Icon(Icons.network_check),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NetworkPage()),
              );
            },
            tooltip: 'Comunicación de Red',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: isSqlite ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            child: Text(
              isSqlite ? 'Persistencia: SQLite (Relacional)' : 'Persistencia: Hive (NoSQL)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSqlite ? Colors.blue : Colors.orange,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text('No hay elementos'))
                    : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSqlite ? Colors.blue.shade50 : Colors.orange.shade50,
                                child: Icon(
                                  IconData(item['iconCode'] ?? Icons.device_unknown.codePoint, fontFamily: 'MaterialIcons'),
                                  color: isSqlite ? Colors.blue : Colors.orange,
                                ),
                              ),
                              title: Text(item['title'] ?? ''),
                              subtitle: Text(item['subtitle'] ?? ''),
                              onTap: () => _openForm(item: item),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteItem(item),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: isSqlite ? Colors.blue : Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
