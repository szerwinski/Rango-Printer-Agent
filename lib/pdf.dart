import 'dart:io';
import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rango_printer_agent/log.dart';
import 'package:rango_printer_agent/paths.dart';
import 'package:rango_printer_agent/types/config.dart';
import 'package:rango_printer_agent/types/http_response.dart';
import 'package:rango_printer_agent/utils.dart';
import 'package:intl/intl.dart';

class PDFService {
  Future<void> printTable(Table table) async {
    num id = Random().nextInt(100);
    String name = '${AppPaths.tmpDir}\\temp-$id.pdf';

    var doc = pw.Document();
    var tableSale = table.tableSale;
    var totalSold = 0.0;
    var requestedItems = tableSale?.data;

    if (requestedItems == null) {
      return;
    }

    for (var item in requestedItems) {
      totalSold += OrderUtils.getPriceForOrderItem(item).toDouble();
    }

    doc = await configureTableSalePdf(
        requestedItems.toList(), (table.name ?? "mesa"), doc,
        totalSold: totalSold, forKitchen: true, isTable: table.isTable);

    final file = File(name);
    await file.writeAsBytes(await doc.save());

    final filePath = name;
    final pdfExecutable = AppPaths.pdfToPrinter;

    if (file.existsSync()) {
      print('Arquivo encontrado em: $filePath');

      try {
        final result = await Process.run(
          pdfExecutable,
          [filePath, globalConfig.printer],
          runInShell: true,
        );

        if (result.exitCode == 0) {
          print('Documento enviado para impressão');
        } else {
          print('Erro ao imprimir: ${result.stderr}');
        }
        // remove the file
        // await file.delete();
        for (var item in requestedItems) {
          if (item.uuid != null) {
            await salvarPedidoImpressao(item.uuid!);
          }
        }
        await file.delete();
      } catch (e) {
        print('Erro ao executar o comando: $e');
      }
    } else {
      await logMessage('Arquivo nao encontrado em: $filePath');
      print('Arquivo não encontrado em: $filePath');
    }
  }

  Future<void> salvarPedidoImpressao(String pedidoId) async {
    final file = File(AppPaths.pedidosImpressos);

    // Verificar se o arquivo já existe
    if (await file.exists()) {
      // Adicionar o ID do pedido ao arquivo
      await file.writeAsString('$pedidoId\n', mode: FileMode.append);
    } else {
      // Criar o arquivo e adicionar o primeiro pedido
      await file.writeAsString('$pedidoId\n');
    }
  }

  Future<List<String>> pedidoJaImpressao(List<String> pedidos) async {
    final file = File(AppPaths.pedidosImpressos);

    List<String> pedidosImpressos = [];

    // Verificar se o arquivo existe
    if (await file.exists()) {
      // Ler todas as linhas do arquivo
      final lines = await file.readAsLines();

      // Verificar se o pedidoId já foi registrado
      for (var pedidoId in pedidos) {
        if (lines.contains(pedidoId)) {
          pedidosImpressos.add(pedidoId);
        }
      }
    }

    // Se o arquivo não existe, nenhum pedido foi impresso
    return pedidosImpressos;
  }

  Future<pw.Document> configureTableSalePdf(
      List<Datum> items, String tableName, doc,
      {bool forKitchen = false,
      bool persistItems = false,
      double? totalSold,
      double? discount,
      double? commission,
      double? couvert,
      double? totalPaid,
      bool? isTable}) async {
    var dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss.SSS");

    doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          var style = pw.TextStyle(fontSize: 10);
          String restaurantName = globalConfig.restaurant.name;
          return pw.Container(
              margin: pw.EdgeInsets.only(right: 10),
              width: PdfPageFormat.roll80.width,
              child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(restaurantName),
                    pw.Text('Impresso em ${dateFormat.format(DateTime.now())}',
                        style: style),
                    pw.Text(
                        forKitchen
                            ? 'Impressão de Pedido'
                            : '*** NÃO É DOCUMENTO FISCAL ***',
                        textAlign: pw.TextAlign.center,
                        style: style.copyWith(
                            fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Text(
                        isTable == false
                            ? 'Comanda: $tableName'
                            : 'Mesa: $tableName',
                        style: style.copyWith(
                            fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: items
                            .map((e) => pw.Container(
                                padding: pw.EdgeInsets.only(right: 5),
                                width: PdfPageFormat.roll80.width,
                                child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Row(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Container(
                                              width: PdfPageFormat.roll80.width,
                                              child: pw.Text(
                                                  "${(e.menuItem)?.byWeight == true ? (e.quantity ?? 0) > 1000000 ? '${((e.quantity ?? 0) / 1000000).toStringAsFixed(2)}kg' : '${((e.quantity ?? 0) / 1000).toStringAsFixed(2)}g' : '${e.quantity}x'} ${e.menuItem!.name!}",
                                                  style: style.copyWith(
                                                      fontWeight: forKitchen
                                                          ? pw.FontWeight.bold
                                                          : pw.FontWeight
                                                              .normal,
                                                      fontSize:
                                                          forKitchen ? 14 : 12),
                                                  overflow:
                                                      pw.TextOverflow.clip,
                                                  maxLines: 2)),
                                        ],
                                      ),
                                      for (int i = 0;
                                          i < e.options!.length;
                                          i++)
                                        pw.Text(
                                            "+ ${e.options![i].quantity}x ${e.options![i].name}",
                                            style: style.copyWith(
                                                color: PdfColor.fromHex(
                                                    '#000000'))),
                                      pw.SizedBox(height: 3),
                                      if (e.note != null && e.note!.isNotEmpty)
                                        pw.Container(
                                            child: pw.Text(
                                                'Nota do item: ${e.note ?? ''}',
                                                style: style.copyWith(
                                                    fontSize: 14))),
                                      if (e.note != null && e.note!.isNotEmpty)
                                        pw.SizedBox(height: 8),
                                    ])))
                            .toList()),
                    pw.Center(
                      child: pw.Text(
                        'RanGo Makers Pro',
                      ),
                    ),
                  ]));
        })); //
    return doc;
  }
}
