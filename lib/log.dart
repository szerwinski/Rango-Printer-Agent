import 'dart:io';

import 'package:rango_printer_agent/paths.dart';

Future<void> logMessage(String message) async {
  final file = File(AppPaths.logFile);
  final dateTime = DateTime.now().toIso8601String();  // Data e hora no formato ISO 8601
  
  // Adiciona a mensagem ao arquivo de log com data e hora
  await file.writeAsString('[$dateTime] $message\n', mode: FileMode.append);
}