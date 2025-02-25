import 'dart:io';
import 'dart:ffi';
import 'package:rango_printer_agent/log.dart';
import 'package:rango_printer_agent/paths.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

late Config globalConfig;

Future<void> initializeConfig() async {
  await logMessage('Iniciando Configuração');
  try {
    await logMessage('Carregando configuração');
    globalConfig = Config.loadFromFile(AppPaths.configFile);
    await logMessage('Configuração carregada');
    print('GraphQL Endpoint: ${globalConfig.graphql.endpoint}');
    print('Restaurant ID: ${globalConfig.restaurant.id}');
    print('Restaurant Name: ${globalConfig.restaurant.name}');
    print('Endpoint: ${globalConfig.endpoint}');
    print('Printer: ${globalConfig.printer}');
  } catch (e) {
    await logMessage('Arquivo de configuração nao encontrado, criando um novo');
    print(e);
    await Config.createFromStdin(AppPaths.configFile);
    globalConfig = Config.loadFromFile(AppPaths.configFile);
  }
}

// Função para listar impressoras disponíveis no Windows
List<String> listAvailablePrinters() {
  final printers = <String>[];
  
  // Aloca buffer para os nomes das impressoras
  final pSize = calloc<DWORD>();
  final flags = PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS;
  
  // Primeira chamada para obter o tamanho necessário do buffer
  EnumPrinters(flags, nullptr, 2, nullptr, 0, pSize, calloc<DWORD>());
  
  final pPrinterInfo = calloc<Uint8>(pSize.value);
  final pcReturned = calloc<DWORD>();
  
  // Segunda chamada para obter as informações das impressoras
  final result = EnumPrinters(
    flags,
    nullptr,
    2,
    pPrinterInfo,
    pSize.value,
    pSize,
    pcReturned,
  );
  
  if (result == 1) {
    final count = pcReturned.value;
    var current = pPrinterInfo;
    
    for (var i = 0; i < count; i++) {
      final printerInfo = current.cast<PRINTER_INFO_2>();
      final printerName = printerInfo.ref.pPrinterName.toDartString();
      printers.add(printerName);
      
      // Avança para o próximo PRINTER_INFO_2
      // ignore: deprecated_member_use
      current = current.elementAt(sizeOf<PRINTER_INFO_2>());
    }
  }
  
  // Libera a memória alocada
  free(pSize);
  free(pPrinterInfo);
  free(pcReturned);
  
  return printers;
}

// Função para selecionar uma impressora da lista
String selectPrinter() {
  final printers = listAvailablePrinters();
  
  if (printers.isEmpty) {
    print('Nenhuma impressora encontrada.');
    return '';
  }

  print('\nImpressoras disponíveis:');
  for (var i = 0; i < printers.length; i++) {
    print('${i + 1}. ${printers[i]}');
  }

  while (true) {
    stdout.write('\nSelecione o número da impressora (1-${printers.length}): ');
    final input = stdin.readLineSync();
    
    if (input == null) continue;
    
    final selection = int.tryParse(input);
    if (selection != null && selection >= 1 && selection <= printers.length) {
      return printers[selection - 1];
    }
    
    print('Seleção inválida. Tente novamente.');
  }
}

class GraphQLConfig {
  final String endpoint;
  final String secret;

  GraphQLConfig({
    required this.endpoint,
    required this.secret,
  });

  factory GraphQLConfig.fromMap(Map<dynamic, dynamic> map) {
    return GraphQLConfig(
      endpoint: map['endpoint'] as String,
      secret: map['secret'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'endpoint': endpoint,
      'secret': secret,
    };
  }
}

class RestaurantConfig {
  final String id;
  final String name;

  RestaurantConfig({
    required this.id,
    required this.name,
  });

  factory RestaurantConfig.fromMap(Map<dynamic, dynamic> map) {
    return RestaurantConfig(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Config {
  final GraphQLConfig graphql;
  final RestaurantConfig restaurant;
  final String endpoint;
  final String printer;

  Config({
    required this.graphql,
    required this.restaurant,
    required this.endpoint,
    required this.printer,
  });

  factory Config.fromMap(Map<dynamic, dynamic> map) {
    return Config(
      graphql: GraphQLConfig.fromMap(map['graphql'] as Map),
      restaurant: RestaurantConfig.fromMap(map['restaurant'] as Map),
      endpoint: map['endpoint'] as String,
      printer: map['printer'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'graphql': graphql.toMap(),
      'restaurant': restaurant.toMap(),
      'endpoint': endpoint,
      'printer': printer,
    };
  }

  static Config loadFromFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('Arquivo $filePath não encontrado.');
    }
    final yamlContent = file.readAsStringSync();
    final yamlMap = loadYaml(yamlContent) as Map;
    return Config.fromMap(yamlMap);
  }

  // Método para criar o arquivo via stdin com seleção de impressora
  static Future<void> createFromStdin(String filePath) async {
    print('--- Criando configuração ---');

    stdout.write('GraphQL Endpoint: ');
    final endpoint = stdin.readLineSync() ?? '';

    stdout.write('GraphQL Secret: ');
    final secret = stdin.readLineSync() ?? '';

    stdout.write('Restaurant ID: ');
    final restaurantId = (stdin.readLineSync() ?? '').trim();

    if (int.tryParse(restaurantId) == null) {
      throw Exception('ID de restaurante inválido.');
    }

    stdout.write('Restaurant Name: ');
    final restaurantName = stdin.readLineSync() ?? '';

    stdout.write('Url para consulta de pedidos: ');
    final endpointUrl = stdin.readLineSync() ?? '';

    // Adiciona seleção de impressora
    print('\nBuscando impressoras disponíveis...');
    final selectedPrinter = selectPrinter();

    if (selectedPrinter.isEmpty) {
      throw Exception('Nenhuma impressora selecionada.');
    }

    final config = Config(
      graphql: GraphQLConfig(endpoint: endpoint, secret: secret),
      restaurant: RestaurantConfig(id: restaurantId, name: restaurantName),
      endpoint: endpointUrl,
      printer: selectedPrinter,
    );

    saveToYamlFile(config, filePath);
    print('\nConfiguração salva em $filePath.');
  }

  // Método para atualizar a impressora padrão
  void updatePrinter(String filePath) {
    print('\nSelecionando nova impressora padrão...');
    final newPrinter = selectPrinter();
    
    if (newPrinter.isNotEmpty) {
      final updatedConfig = Config(
        graphql: graphql,
        restaurant: restaurant,
        endpoint: endpoint,
        printer: newPrinter,
      );
      
      saveToYamlFile(updatedConfig, filePath);
      print('Impressora padrão atualizada para: $newPrinter');
    }
  }

  // Método para salvar em YAML
  void saveToFile(String filePath) {
    saveToYamlFile(this, filePath);
  }
}

// Função auxiliar para salvar em YAML
void saveToYamlFile(Config config, String filePath) {
  final writer = YamlWriter();
  final yaml = writer.write(config.toMap());
  File(filePath).writeAsStringSync(yaml);
}