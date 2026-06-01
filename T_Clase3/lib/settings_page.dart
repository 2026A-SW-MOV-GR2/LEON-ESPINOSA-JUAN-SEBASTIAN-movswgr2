import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum StorageMechanism {
  sharedPreferences,
  dataStore,
  encryptedSharedPreferences
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  StorageMechanism _selectedMechanism = StorageMechanism.sharedPreferences;
  String _retrievedValue = '';
  final _secureStorage = const FlutterSecureStorage();

  Future<void> _saveSecret() async {
    final key = _keyController.text.trim();
    final value = _valueController.text.trim();

    if (key.isEmpty || value.isEmpty) {
      _showSnackBar('Llave y Valor son requeridos');
      return;
    }

    try {
      switch (_selectedMechanism) {
        case StorageMechanism.sharedPreferences:
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(key, value);
          break;
        case StorageMechanism.dataStore:
          // En Flutter, shared_preferences usa DataStore internamente en versiones modernas de Android,
          // pero para diferenciarlo académicamente, usaremos un prefijo o un mecanismo distinto.
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('ds_$key', value);
          break;
        case StorageMechanism.encryptedSharedPreferences:
          await _secureStorage.write(key: key, value: value);
          break;
      }
      _showSnackBar('Guardado exitosamente en ${_getMechanismName(_selectedMechanism)}');
      _valueController.clear();
    } catch (e) {
      _showSnackBar('Error al guardar: $e');
    }
  }

  Future<void> _retrieveSecret() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      _showSnackBar('Ingrese una llave para recuperar');
      return;
    }

    String? value;
    try {
      switch (_selectedMechanism) {
        case StorageMechanism.sharedPreferences:
          final prefs = await SharedPreferences.getInstance();
          value = prefs.getString(key);
          break;
        case StorageMechanism.dataStore:
          final prefs = await SharedPreferences.getInstance();
          value = prefs.getString('ds_$key');
          break;
        case StorageMechanism.encryptedSharedPreferences:
          value = await _secureStorage.read(key: key);
          break;
      }

      setState(() {
        if (value != null) {
          _retrievedValue = value!;
        } else {
          _retrievedValue = 'Secreto no encontrado';
        }
      });
    } catch (e) {
      _showSnackBar('Error al recuperar: $e');
    }
  }

  String _getMechanismName(StorageMechanism mechanism) {
    switch (mechanism) {
      case StorageMechanism.sharedPreferences:
        return 'SharedPreferences';
      case StorageMechanism.dataStore:
        return 'DataStore';
      case StorageMechanism.encryptedSharedPreferences:
        return 'EncryptedSharedPreferences';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Secretos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Almacenamiento Seguro y Configuración',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _keyController,
                decoration: const InputDecoration(
                  labelText: 'Llave (Key)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Valor (Value)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.text_fields),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Seleccionar Mecanismo:', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<StorageMechanism>(
                value: _selectedMechanism,
                isExpanded: true,
                onChanged: (StorageMechanism? newValue) {
                  setState(() {
                    _selectedMechanism = newValue!;
                    _retrievedValue = ''; // Limpiar valor al cambiar mecanismo
                  });
                },
                items: StorageMechanism.values.map((StorageMechanism mechanism) {
                  return DropdownMenuItem<StorageMechanism>(
                    value: mechanism,
                    child: Text(_getMechanismName(mechanism)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveSecret,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _retrieveSecret,
                      icon: const Icon(Icons.search),
                      label: const Text('Recuperar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              if (_retrievedValue.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _retrievedValue == 'Secreto no encontrado' ? Colors.red.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      const Text('Resultado:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        _retrievedValue,
                        style: TextStyle(
                          fontSize: 16,
                          color: _retrievedValue == 'Secreto no encontrado' ? Colors.red : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
