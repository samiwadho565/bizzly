class InvoiceItemModel {
  InvoiceItemModel({
    this.id,
    required this.itemName,
    this.qty,
    this.unitPrice,
    this.totalAmount,
    this.sortOrder,
  });

  final int? id;
  final String itemName;
  final dynamic qty;
  final dynamic unitPrice;
  final dynamic totalAmount;
  final int? sortOrder;

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: _toInt(json['id']),
      itemName: json['item_name']?.toString() ?? '',
      qty: json['qty'],
      unitPrice: json['unit_price'],
      totalAmount: json['total_amount'],
      sortOrder: _toInt(json['sort_order']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'qty': _toInt(qty),
      'unit_price': _toAmountString(unitPrice),
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static String? _toAmountString(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toStringAsFixed(2);
    final String raw = value.toString().trim();
    if (raw.isEmpty) return null;
    final num? parsed = num.tryParse(raw);
    if (parsed != null) return parsed.toStringAsFixed(2);
    return raw;
  }
}
