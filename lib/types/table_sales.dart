class TableSalesComponent {
  final int id;
  final int componentId;

  TableSalesComponent({
    required this.id,
    required this.componentId,
  });

  factory TableSalesComponent.fromJson(Map<String, dynamic> json) {
    return TableSalesComponent(
      id: json['id'] as int,
      componentId: json['component_id'] as int,
    );
  }
}

class TableSale {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final List<TableSalesComponent> tableSalesComponents;

  TableSale({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.tableSalesComponents,
  });

  factory TableSale.fromJson(Map<String, dynamic> json) {
    return TableSale(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: json['status'] as String,
      tableSalesComponents: (json['table_sales_components'] as List)
          .map((e) => TableSalesComponent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  List<int> get componentIds => 
      tableSalesComponents.map((component) => component.componentId).toList();
}



