// To parse this JSON data, do
//
//     final table = tableFromJson(jsonString);

import 'dart:convert';

List<Table> tableFromJson(String str) =>
    List<Table>.from(json.decode(str).map((x) => Table.fromJson(x)));

String tableToJson(List<Table> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Table {
  num? id;
  String? name;
  String? status;
  bool? isTable;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic publishedAt;
  num? index;
  TableSale? tableSale;

  Table({
    this.id,
    this.name,
    this.status,
    this.isTable,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
    this.index,
    this.tableSale,
  });

  factory Table.fromJson(Map<String, dynamic> json) => Table(
        id: json["id"],
        name: json["name"],
        status: json["status"],
        isTable: json["isTable"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        publishedAt: json["publishedAt"],
        index: json["index"],
        tableSale: json["tableSale"] == null
            ? null
            : TableSale.fromJson(json["tableSale"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "status": status,
        "isTable": isTable,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "publishedAt": publishedAt,
        "index": index,
        "tableSale": tableSale?.toJson(),
      };
}

class TableSale {
  num? id;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic authorizedSefaz;
  dynamic xml;
  dynamic xmlOffline;
  dynamic publishedAt;
  String? history;
  List<Datum>? data;

  TableSale({
    this.id,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.authorizedSefaz,
    this.xml,
    this.xmlOffline,
    this.publishedAt,
    this.history,
    this.data,
  });

  factory TableSale.fromJson(Map<String, dynamic> json) => TableSale(
        id: json["id"],
        status: json["status"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        authorizedSefaz: json["authorizedSEFAZ"],
        xml: json["xml"],
        xmlOffline: json["xmlOffline"],
        publishedAt: json["publishedAt"],
        history: json["history"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "authorizedSEFAZ": authorizedSefaz,
        "xml": xml,
        "xmlOffline": xmlOffline,
        "publishedAt": publishedAt,
        "history": history,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  num? id;
  num? quantity;
  bool? fidelityRescue;
  bool fromMobile;
  dynamic note;
  String? status;
  num? freePrice;
  dynamic discount;
  List<Option>? options;
  MenuItem? menuItem;
  String? uuid;

  Datum(
      {this.id,
      this.quantity,
      this.fidelityRescue,
      this.note,
      this.status,
      this.freePrice,
      this.discount,
      this.options,
      this.menuItem,
      this.fromMobile = false,
      this.uuid});

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        quantity: json["quantity"],
        fidelityRescue: json["fidelityRescue"],
        fromMobile: json["fromMobile"],
        note: json["note"],
        status: json["status"],
        freePrice: json["freePrice"],
        discount: json["discount"],
        options: json["options"] == null
            ? []
            : List<Option>.from(
                json["options"]!.map((x) => Option.fromJson(x))),
        menuItem: json["menu_item"] == null
            ? null
            : MenuItem.fromJson(json["menu_item"]),
        uuid: json["uuid"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "quantity": quantity,
        "fidelityRescue": fidelityRescue,
        "note": note,
        "status": status,
        "freePrice": freePrice,
        "discount": discount,
        "options": options == null
            ? []
            : List<dynamic>.from(options!.map((x) => x.toJson())),
        "menu_item": menuItem?.toJson(),
        "uuid": uuid
      };
}

class MenuItem {
  num? id;
  String? name;
  String? description;
  String? largeImageUrl;
  String? thumbnailImageUrl;
  num? price;
  bool? status;
  bool? onSale;
  num? promotionalPrice;
  bool? generic;
  DateTime? createdAt;
  DateTime? updatedAt;
  num? index;
  String? icon;
  String? promotionalType;
  dynamic isScheduled;
  num? code;
  num? stock;
  num? costPrice;
  String? unit;
  bool? byWeight;
  String? ncm;
  bool? blockPrinting;
  String? barCode;
  dynamic freePrice;
  List<OptionsCategory>? optionsCategories;
  MenuItemsCategory? menuItemsCategory;

  MenuItem({
    this.id,
    this.name,
    this.description,
    this.largeImageUrl,
    this.thumbnailImageUrl,
    this.price,
    this.status,
    this.onSale,
    this.promotionalPrice,
    this.generic,
    this.createdAt,
    this.updatedAt,
    this.index,
    this.icon,
    this.promotionalType,
    this.isScheduled,
    this.code,
    this.stock,
    this.costPrice,
    this.unit,
    this.byWeight,
    this.ncm,
    this.blockPrinting,
    this.barCode,
    this.freePrice,
    this.optionsCategories,
    this.menuItemsCategory,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        largeImageUrl: json["largeImageUrl"],
        thumbnailImageUrl: json["thumbnailImageUrl"],
        price: json["price"],
        status: json["status"],
        onSale: json["onSale"],
        promotionalPrice: json["promotionalPrice"]?.toDouble(),
        generic: json["generic"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        index: json["index"],
        icon: json["icon"],
        promotionalType: json["promotionalType"],
        isScheduled: json["isScheduled"],
        code: json["code"],
        stock: json["stock"],
        costPrice: json["costPrice"],
        unit: json["unit"],
        byWeight: json["byWeight"],
        ncm: json["ncm"],
        blockPrinting: json["blockPrinting"],
        barCode: json["barCode"],
        freePrice: json["freePrice"],
        optionsCategories: json["optionsCategories"] == null
            ? []
            : List<OptionsCategory>.from(json["optionsCategories"]!
                .map((x) => OptionsCategory.fromJson(x))),
        menuItemsCategory: json["menu_items_category"] == null
            ? null
            : MenuItemsCategory.fromJson(json["menu_items_category"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "largeImageUrl": largeImageUrl,
        "thumbnailImageUrl": thumbnailImageUrl,
        "price": price,
        "status": status,
        "onSale": onSale,
        "promotionalPrice": promotionalPrice,
        "generic": generic,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "index": index,
        "icon": icon,
        "promotionalType": promotionalType,
        "isScheduled": isScheduled,
        "code": code,
        "stock": stock,
        "costPrice": costPrice,
        "unit": unit,
        "byWeight": byWeight,
        "ncm": ncm,
        "blockPrinting": blockPrinting,
        "barCode": barCode,
        "freePrice": freePrice,
        "optionsCategories": optionsCategories == null
            ? []
            : List<dynamic>.from(optionsCategories!.map((x) => x.toJson())),
        "menu_items_category": menuItemsCategory?.toJson(),
      };
}

class MenuItemsCategory {
  num? id;
  String? name;
  num? index;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? rewardEnabled;
  num? rewardPrize;
  String? largeImageUrl;

  MenuItemsCategory({
    this.id,
    this.name,
    this.index,
    this.createdAt,
    this.updatedAt,
    this.rewardEnabled,
    this.rewardPrize,
    this.largeImageUrl,
  });

  factory MenuItemsCategory.fromJson(Map<String, dynamic> json) =>
      MenuItemsCategory(
        id: json["id"],
        name: json["name"],
        index: json["index"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        rewardEnabled: json["rewardEnabled"],
        rewardPrize: json["rewardPrize"],
        largeImageUrl: json["largeImageUrl"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "index": index,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "rewardEnabled": rewardEnabled,
        "rewardPrize": rewardPrize,
        "largeImageUrl": largeImageUrl,
      };
}

class OptionsCategory {
  num? id;
  String? categoryName;
  num? index;
  bool? isOptional;
  num? minOptions;
  num? maxOptions;
  List<Option>? options;

  OptionsCategory({
    this.id,
    this.categoryName,
    this.index,
    this.isOptional,
    this.minOptions,
    this.maxOptions,
    this.options,
  });

  factory OptionsCategory.fromJson(Map<String, dynamic> json) =>
      OptionsCategory(
        id: json["id"],
        categoryName: json["categoryName"],
        index: json["index"],
        isOptional: json["isOptional"],
        minOptions: json["minOptions"],
        maxOptions: json["maxOptions"],
        options: json["options"] == null
            ? []
            : List<Option>.from(
                json["options"]!.map((x) => Option.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "categoryName": categoryName,
        "index": index,
        "isOptional": isOptional,
        "minOptions": minOptions,
        "maxOptions": maxOptions,
        "options": options == null
            ? []
            : List<dynamic>.from(options!.map((x) => x.toJson())),
      };
}

class Option {
  num? id;
  String? largeImageUrl;
  String? thumbnailImageUrl;
  String? name;
  num? price;
  dynamic description;
  num? quantity;
  bool? status;

  Option({
    this.id,
    this.largeImageUrl,
    this.thumbnailImageUrl,
    this.name,
    this.price,
    this.description,
    this.quantity,
    this.status,
  });

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        id: json["id"],
        largeImageUrl: json["largeImageUrl"],
        thumbnailImageUrl: json["thumbnailImageUrl"],
        name: json["name"],
        price: json["price"]?.toDouble(),
        description: json["description"],
        quantity: json["quantity"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "largeImageUrl": largeImageUrl,
        "thumbnailImageUrl": thumbnailImageUrl,
        "name": name,
        "price": price,
        "description": description,
        "quantity": quantity,
        "status": status,
      };
}
