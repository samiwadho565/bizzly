class InvoicePaymentModel {
  InvoicePaymentModel({
    this.id,
    this.invoiceId,
    this.paymentAmount,
    this.paymentDate,
    this.referenceNumber,
    this.notes,
    this.paymentMethodId,
    this.paymentMethodName,
    this.userId,
    this.userName,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? invoiceId;
  final dynamic paymentAmount;
  final String? paymentDate;
  final String? referenceNumber;
  final String? notes;
  final int? paymentMethodId;
  final String? paymentMethodName;
  final int? userId;
  final String? userName;
  final String? createdAt;
  final String? updatedAt;

  factory InvoicePaymentModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final Map<String, dynamic>? paymentMethod = payload['payment_method'] is Map
        ? Map<String, dynamic>.from(payload['payment_method'] as Map)
        : null;
    final Map<String, dynamic>? user = payload['user'] is Map
        ? Map<String, dynamic>.from(payload['user'] as Map)
        : null;

    return InvoicePaymentModel(
      id: _toInt(payload['id']),
      invoiceId: _toInt(payload['invoice_id']),
      paymentAmount: payload['payment_amount'],
      paymentDate: payload['payment_date']?.toString(),
      referenceNumber: payload['reference_number']?.toString(),
      notes: payload['notes']?.toString(),
      paymentMethodId: _toInt(paymentMethod?['id'] ?? payload['payment_method_id']),
      paymentMethodName: paymentMethod?['name']?.toString(),
      userId: _toInt(user?['id'] ?? payload['user_id']),
      userName: user?['name']?.toString(),
      createdAt: payload['created_at']?.toString(),
      updatedAt: payload['updated_at']?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}
