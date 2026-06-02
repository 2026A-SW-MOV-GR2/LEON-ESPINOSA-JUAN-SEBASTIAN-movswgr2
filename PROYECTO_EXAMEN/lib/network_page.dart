import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  
  bool _isLoading = false;
  int? _currentId;

  Future<void> _fetchPost() async {
    final id = _idController.text.trim();
    if (id.isEmpty) return;

    setState(() {
      _isLoading = true;
      _currentId = null; // Reiniciar para ocultar el formulario previo durante la carga
    });
    debugPrint('[INFO] HTTP: Iniciando petición GET a /posts/$id');

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('[DEBUG] HTTP: Datos obtenidos correctamente');
        setState(() {
          _currentId = int.tryParse(id);
          _titleController.text = data['title'] ?? '';
          _bodyController.text = data['body'] ?? '';
        });
      } else {
        debugPrint('[ERROR] HTTP: Error en petición GET: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('[ERROR] HTTP: Fallo de conexión: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePost() async {
    if (_currentId == null) return;

    setState(() => _isLoading = true);
    debugPrint('[INFO] HTTP: Enviando petición PUT para ID: $_currentId');

    try {
      final response = await http.put(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/$_currentId'),
        headers: {'Content-type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'id': _currentId,
          'title': _titleController.text,
          'body': _bodyController.text,
          'userId': 1,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('[DEBUG] HTTP: Actualización exitosa (200 OK)');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Actualizado con éxito (200 OK)')),
        );
        setState(() {
          _titleController.text = data['title'];
          _bodyController.text = data['body'];
        });
      } else {
        debugPrint('[ERROR] HTTP: Error en actualización: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('[ERROR] HTTP: Fallo de conexión al actualizar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunicación de Red'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _idController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: 'ID del Post',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _fetchPost,
                    child: const Text('Obtener'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_currentId != null) ...[
                const Divider(),
                const Text('Formulario Editable', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: _titleController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _bodyController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Cuerpo',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _isLoading ? null : _updatePost,
                  child: const Text('Actualizar'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
