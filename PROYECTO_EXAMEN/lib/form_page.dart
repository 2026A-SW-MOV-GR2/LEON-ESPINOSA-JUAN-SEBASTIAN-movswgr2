import 'package:flutter/material.dart';

class FormPage extends StatefulWidget {
  final Map<String, dynamic>? item;

  const FormPage({super.key, this.item});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;

  DateTime? _selectedDate;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.item?['title'] ?? '');
    _subtitleController =
        TextEditingController(text: widget.item?['subtitle'] ?? '');

    _selectedDate = widget.item?['date'];
    _isActive = widget.item?['active'] ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() {
    final result = {
      'title': _titleController.text,
      'subtitle': _subtitleController.text,
      'date': _selectedDate,
      'active': _isActive,
    };

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Elemento' : 'Nuevo Elemento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(
                labelText: 'Subtítulo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _selectedDate == null
                    ? 'Seleccionar fecha'
                    : 'Fecha: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            SwitchListTile(
              title: const Text('Activo'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const Spacer(),
            FilledButton(
              onPressed: _save,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}