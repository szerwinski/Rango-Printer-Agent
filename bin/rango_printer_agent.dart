import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:rango_printer_agent/graphql.dart';
import 'package:rango_printer_agent/log.dart';
import 'package:rango_printer_agent/types/config.dart';

void main(List<String> arguments) async {
  var runner = CommandRunner('rango-printer', 'Gerenciador de impressão do Rango')
    ..addCommand(StartupCommand())
    ..addCommand(RunCommand());

  try {
    await runner.run(arguments.isEmpty ? ['run'] : arguments);
  } catch (error) {
    if (error is! UsageException) {
      print('Erro: $error');
      exit(1);
    }
    print(error);
    exit(64);
  }
}

class RunCommand extends Command {
  @override
  final name = 'run';
  @override
  final description = 'Inicia o serviço de impressão';

  @override
  Future<void> run() async {
    await logMessage('Iniciando Rango Printer Agent');
    await initializeConfig();
    GraphqlService.listenPrinters();
  }
}

class StartupCommand extends Command {
  @override
  final name = 'startup';
  @override
  final description = 'Gerencia inicialização com Windows';

  StartupCommand() {
    addSubcommand(EnableStartupCommand());
    addSubcommand(DisableStartupCommand());
  }
}

class EnableStartupCommand extends Command {
  @override
  final name = 'enable';
  @override
  final description = 'Habilita inicialização com Windows';

  @override
  Future<void> run() async {
    final startupFolder = Platform.environment['APPDATA']! + 
      r'\Microsoft\Windows\Start Menu\Programs\Startup';
    final shortcutPath = '$startupFolder\\RangoPrinter.lnk';
    final executablePath = Platform.executable;

    final result = await Process.run('powershell', [
      '-Command',
      '''
      \$WScriptShell = New-Object -ComObject WScript.Shell;
      \$Shortcut = \$WScriptShell.CreateShortcut('$shortcutPath');
      \$Shortcut.TargetPath = '$executablePath';
      \$Shortcut.Arguments = 'run';
      \$Shortcut.Save();
      '''
    ]);

    if (result.exitCode == 0) {
      print('Rango Printer configurado para iniciar com Windows');
    } else {
      print('Erro ao configurar inicialização automática');
      print(result.stderr);
    }
  }
}

class DisableStartupCommand extends Command {
  @override
  final name = 'disable';
  @override
  final description = 'Desabilita inicialização com Windows';

  @override
  Future<void> run() async {
    final startupFolder = Platform.environment['APPDATA']! + 
      r'\Microsoft\Windows\Start Menu\Programs\Startup';
    final shortcutPath = '$startupFolder\\RangoPrinter.lnk';

    final result = await Process.run('powershell', [
      '-Command',
      'Remove-Item "$shortcutPath" -Force -ErrorAction SilentlyContinue'
    ]);

    if (result.exitCode == 0) {
      print('Rango Printer removido da inicialização do Windows');
    } else {
      print('Erro ao remover inicialização automática');
      print(result.stderr);
    }
  }
}