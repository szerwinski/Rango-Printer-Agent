import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rango_printer_agent/log.dart';
import 'package:rango_printer_agent/types/config.dart';


import 'types/http_response.dart';

class TableService {
  static String baseUrl = globalConfig.endpoint;

  static Future<List<Table>> getTables({
    required String restaurantId,
    required int tableSaleId,
  }) async {
    try {
      final queryParameters = {
        'filters[restaurant]': restaurantId,
        'filters[tableSale][id]': tableSaleId.toString(),
        'populate[0]': 'tableSale',
        'populate[1]': 'tableSale.data',
        'populate[2]': 'tableSale.data.options',
        'populate[3]': 'tableSale.data.menu_item',
        'populate[4]': 'tableSale.data.menu_item.menu_items_category',
        'populate[10]': 'tableSale.data.menu_item.optionsCategories',
        'populate[11]': 'tableSale.data.menu_item.optionsCategories.options',
      };

      final uri = Uri.parse('$baseUrl/tables')
          .replace(queryParameters: queryParameters);

      print(uri);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Adicione headers de autenticação se necessário
          // 'Authorization': 'Bearer your_token_here',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Table.fromJson(json)).toList();
      } else {
        logMessage("Failed to load tables: ${response.statusCode}");
        throw HttpException('Failed to load tables: ${response.statusCode}');
      }
    } catch (e) {
      logMessage("Failed to load tables: $e");
      print('Error fetching tables: $e');
      rethrow;
    }
  }
}
