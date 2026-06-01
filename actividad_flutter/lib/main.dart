import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver {

  static const platform = MethodChannel('resource_channel');

  String text = "Cargando...";
  Color textColor = Colors.black;
  Color bgColor = Colors.white;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadResources();
  }

  Future<void> loadResources() async {
    try {
      final result = await platform.invokeMethod('getResources');
      final data = Map<String, dynamic>.from(result);

      setState(() {
        text = data["text"];
        textColor = Color(data["textColor"] as int).withOpacity(1.0);
        bgColor = Color(data["backgroundColor"] as int).withOpacity(1.0);
      });
    } catch (e) {
      print("Error en MethodChannel: $e");
    }
  }

  // 🔥 Detecta rotación de pantalla
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    loadResources();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24,
            color: textColor,
          ),
        ),
      ),
    );
  }
}