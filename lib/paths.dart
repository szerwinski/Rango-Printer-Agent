import 'dart:io';
import 'package:path/path.dart' as path;
class AppPaths {
  AppPaths._();

  // Diretório base da aplicação
  static String get baseDir {
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile == null || userProfile.isEmpty) {
      throw Exception('Não foi possível determinar o diretório do usuário (USERPROFILE)');
    }
    return path.join(userProfile, '.rango-printer');
  }

  // Arquivo de configuração
  static String get configFile => path.join(baseDir, 'config.yaml');
  
  // Arquivo de log
  static String get logFile => path.join(baseDir, 'app.log');

  //tmp folder
  static String get tmpDir => path.join(baseDir, 'tmp');

  // pdf to printer
  static String get pdfToPrinter => path.join(baseDir, 'PDFtoPrinter.exe');

  // pedidos impressos
  static String get pedidosImpressos => path.join(baseDir, 'pedidos_impressos.txt');


  // Garante que o diretório base existe
  static void ensureDirectoryExists() {
    final directory = Directory(baseDir);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
  }
}