class InvoiceItemModel {
  InvoiceItemModel({
    this.id,
    required this.itemName,
    required this.amount,
    this.sortOrder,
  });

  final int? id;
  final String itemName;
  final dynamic amount;
  final int? sortOrder;

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: _toInt(json['id']),
      itemName: json['item_name']?.toString() ?? '',
      amount: json['amount'],
      sortOrder: _toInt(json['sort_order']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'amount': amount,
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
