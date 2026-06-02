import 'package:flutter/services.dart';

class NativeToast {
  static const MethodChannel _channel =
  MethodChannel('com.example.clase3/toast');

  static Future<void> show(String message) async {
    try {
      await _channel.invokeMethod('showToast', {
        'message': message,
      });
    } on PlatformException catch (e) {
      print('Error al mostrar Toast nativo: ${e.message}');
    }
  }
}