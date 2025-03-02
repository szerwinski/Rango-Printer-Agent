import 'dart:async';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:rango_printer_agent/http.dart';
import 'package:rango_printer_agent/pdf.dart';
import 'package:rango_printer_agent/types/config.dart';
import 'log.dart';
import 'types/table_sales.dart';

class GraphqlService {
  GraphqlService._();

  static HasuraConnect hasuraConnect = HasuraConnect(
    globalConfig.graphql.endpoint,
    headers: {"x-hasura-admin-secret": globalConfig.graphql.secret},
    reconnectionAttempt: 9999,
  );

  static Future<void> listenPrinters() async {
    final subscriptionDocument = r'''
subscription GetTableSaleComponents($restaurantId: Int!, $updated_at: timestamp) {
  table_sales(where: {table_sales_restaurant_links: {restaurant_id: {_eq: $restaurantId}}, status: {_eq: "OPEN"}, updated_at: {_gt: $updated_at}}, order_by: {updated_at: desc}) {
    id
    created_at
    updated_at
    status
    table_sales_components(where: {component_type: {_eq: "order.data"}}) {
      id
      component_id
    }
  }
}
    ''';
    final startTime =
        DateTime.now().add(const Duration(seconds: -30)).toString();
    Snapshot snapshot = await hasuraConnect.subscription(
      subscriptionDocument,
      variables: {
        "restaurantId": globalConfig.restaurant.id,
        "updated_at": startTime,
      },
    );

    snapshot.listen((data) async {
      final List<TableSale> tableSales = (data['data']['table_sales'] as List)
          .map((sale) => TableSale.fromJson(sale as Map<String, dynamic>))
          .toList();

      for (var element in tableSales) {
        await getReadyOrders(element.componentIds, element.id);
      }
    }).onError((err) {
      logMessage('Erro ao escutar os pedidos: $err');
      print(err);
    });
  }

  static Future<void> getReadyOrders(
      List<int> componentIds, int idTable) async {
    final getReadyOrdersQuery = r'''
      query GetOrderDataDetails($componentIds: [Int!]) {
        components_order_data_aggregate(
          where: {status: {_eq: "READY"}, id: {_in: $componentIds}}
        ) {
          aggregate {
            count(columns: id)
          }
        }
      }
    ''';

    try {
      final response = await hasuraConnect.query(
        getReadyOrdersQuery,
        variables: {"componentIds": componentIds},
      );

      final count = response['data']['components_order_data_aggregate']
          ['aggregate']['count'] as int;
      await logMessage("Imprimindo $count pedidos");

      if (count > 0) {
        var tables = await TableService.getTables(
          restaurantId: globalConfig.restaurant.id,
          tableSaleId: idTable,
        );

        for (var table in tables) {
          if (table.tableSale == null || table.tableSale!.data == null) {
            continue;
          }

          // Create a copy of the table to avoid modifying the original
          var processedTable = table;

          // Get list of already printed orders
          List<String> printedOrders = await PDFService().pedidoJaImpressao(
              processedTable.tableSale!.data!
                  .where((e) => e.uuid != null && e.status == "READY")
                  .map((e) => e.uuid.toString())
                  .toList());

          // Filter out already printed orders and only items from mobile
          var remainingOrders = processedTable.tableSale!.data!
              .where((item) =>
                  !printedOrders.contains(item.uuid.toString()) &&
                  item.status == "READY" &&
                  item.fromMobile == true)
              .toList();

          // Update the table's data with the filtered list
          processedTable.tableSale!.data = remainingOrders;

          // Only print if there are new orders
          if (remainingOrders.isNotEmpty) {
            await PDFService().printTable(processedTable);
          }
        }
      }
    } catch (e) {
      logMessage('Error getting ready orders: $e');
      print(e);
    }
  }
}
